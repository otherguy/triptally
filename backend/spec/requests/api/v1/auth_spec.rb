# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/api/v1/auth/register' do
    post 'User Registration' do
      tags 'Authentication'
      description 'Create a new user account'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: 'John Doe',
          },
          email: {
            type: :string,
            format: :email,
            example: 'john@example.com',
          },
          password: {
            type: :string,
            minLength: 6,
            example: 'password123',
          },
        },
        required: %w[name email password],
      }

      response '201', 'User created successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'User created successfully',
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
              },
            },
            token: {
              type: :string,
              example: 'eyJhbGciOiJIUzI1NiJ9...',
            },
          }

        let(:user_data) do
          {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
          }
        end

        run_test!
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string },
            },
          }

        let(:user_data) do
          {
            name: '',
            email: 'invalid-email',
            password: '123',
          }
        end

        run_test!
      end

      response '400', 'Missing required parameters' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Missing required parameters: name, email',
            },
          }

        let(:user_data) do
          {
            password: 'password123',
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/auth/login' do
    post 'User login' do
      tags 'Authentication'
      description 'Authenticate user and get JWT token'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: {
            type: :string,
            format: :email,
            example: 'john@example.com',
          },
          password: {
            type: :string,
            example: 'password123',
          },
        },
        required: %w[email password],
      }

      response '200', 'Login successful' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Login successful',
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
              },
            },
            token: {
              type: :string,
              example: 'eyJhbGciOiJIUzI1NiJ9...',
            },
          }

        let!(:user) { User.create!(name: 'John Doe', email: 'john@example.com', password: 'password123') }
        let(:credentials) do
          {
            email: 'john@example.com',
            password: 'password123',
          }
        end

        run_test!
      end

      response '401', 'Invalid credentials' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Invalid email or password',
            },
          }

        let!(:user) { User.create!(name: 'John Doe', email: 'john@example.com', password: 'password123') }
        let(:credentials) do
          {
            email: 'john@example.com',
            password: 'wrongpassword',
          }
        end

        run_test!
      end

      response '400', 'Missing required parameters' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Missing required parameters: email, password',
            },
          }

        let(:credentials) do
          {
            email: 'john@example.com',
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'User logout' do
      tags 'Authentication'
      description 'Logout user (currently stateless - just returns success message)'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Logged out successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Logged out successfully',
            },
          }

        let!(:user) { User.create!(name: 'John Doe', email: 'john@example.com', password: 'password123') }
        let(:Authorization) do
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          "Bearer #{JWT.encode(payload, Rails.application.secret_key_base, 'HS256')}"
        end

        run_test!
      end

      response '401', 'Missing or invalid token' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Invalid token',
            },
          }

        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end
end
