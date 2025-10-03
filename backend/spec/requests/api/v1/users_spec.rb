# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { User.create!(name: 'John Doe', email: 'john@example.com', password: 'password123') }
  let(:Authorization) do
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    "Bearer #{JWT.encode(payload, Rails.application.secret_key_base, 'HS256')}"
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'User ID'

    get 'Get user profile' do
      tags 'Users'
      description 'Get current user profile information'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'User profile retrieved' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string },
                created_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:id) { user.id }

        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Invalid token'
            }
          }

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { user.id }

        run_test!
      end
    end

    patch 'Update user profile' do
      tags 'Users'
      description 'Update current user profile'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: 'Jane Doe'
          },
          email: {
            type: :string,
            format: :email,
            example: 'jane@example.com'
          }
        }
      }

      response '200', 'Profile updated successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Profile updated successfully'
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string }
              }
            }
          }

        let(:id) { user.id }
        let(:user_data) do
          {
            name: 'Jane Doe',
            email: 'jane@example.com'
          }
        end

        run_test!
      end

      response '200', 'Profile partially updated (name only)' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Profile updated successfully'
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string }
              }
            }
          }

        let(:id) { user.id }
        let(:user_data) do
          {
            name: 'Jane Updated Name Only'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          user_response = data['user']

          # Verify that only name changed, email remains unchanged
          expect(user_response['name']).to eq('Jane Updated Name Only')
          expect(user_response['email']).to eq('john@example.com') # Original email
        end
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }

        let(:id) { user.id }
        let(:user_data) do
          {
            name: '',
            email: 'invalid-email'
          }
        end

        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Invalid token'
            }
          }

        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { user.id }
        let(:user_data) do
          {
            name: 'Jane Doe'
          }
        end

        run_test!
      end
    end

    put 'Replace user profile (PUT)' do
      tags 'Users'
      description 'Replace user profile entirely (full replacement - requires all fields)'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: 'Jane Doe'
          },
          email: {
            type: :string,
            format: :email,
            example: 'jane@example.com'
          }
        },
        required: %w[name email]
      }

      response '200', 'Profile replaced successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Profile replaced successfully'
            },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                email: { type: :string }
              }
            }
          }

        let(:id) { user.id }
        let(:user_data) do
          {
            name: 'Jane Doe Replaced',
            email: 'jane.replaced@example.com'
          }
        end

        run_test!
      end

      response '400', 'Missing required parameters' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Missing required parameters: email'
            }
          }

        let(:id) { user.id }
        let(:user_data) do
          {
            name: 'Jane Doe'
          }
        end

        run_test!
      end
    end
  end
end