# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Trips API', type: :request do
  let!(:user) { User.create!(name: 'John Doe', email: 'john@example.com', password: 'password123') }
  let!(:trip) do
    user.trips.create!(
      title: 'Summer Vacation',
      description: 'A relaxing trip to the beach',
      start_date: '2024-07-01',
      end_date: '2024-07-07'
    )
  end

  let(:Authorization) do
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    "Bearer #{JWT.encode(payload, Rails.application.secret_key_base, 'HS256')}"
  end

  path '/api/v1/trips' do
    get 'List user trips' do
      tags 'Trips'
      description 'Get all trips for the authenticated user'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Trips retrieved successfully' do
        schema type: :object,
          properties: {
            trips: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  title: { type: :string },
                  description: { type: :string },
                  start_date: {
                    type: :string,
                    format: :date
                  },
                  end_date: {
                    type: :string,
                    format: :date
                  },
                  created_at: {
                    type: :string,
                    format: :datetime
                  },
                  updated_at: {
                    type: :string,
                    format: :datetime
                  }
                }
              }
            }
          }

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

        run_test!
      end
    end

    post 'Create a new trip' do
      tags 'Trips'
      description 'Create a new trip for the authenticated user'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :trip_data, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string,
            example: 'Winter Getaway'
          },
          description: {
            type: :string,
            example: 'A cozy mountain retreat'
          },
          start_date: {
            type: :string,
            format: :date,
            example: '2024-12-20'
          },
          end_date: {
            type: :string,
            format: :date,
            example: '2024-12-27'
          }
        },
        required: %w[title]
      }

      response '201', 'Trip created successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip created successfully'
            },
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: { type: :string },
                start_date: {
                  type: :string,
                  format: :date
                },
                end_date: {
                  type: :string,
                  format: :date
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:trip_data) do
          {
            title: 'Winter Getaway',
            description: 'A cozy mountain retreat',
            start_date: '2024-12-20',
            end_date: '2024-12-27'
          }
        end

        run_test!
      end

      response '201', 'Trip created successfully without dates' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip created successfully'
            },
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: {
                  type: :string,
                  nullable: true
                },
                start_date: {
                  type: :string,
                  format: :date,
                  nullable: true
                },
                end_date: {
                  type: :string,
                  format: :date,
                  nullable: true
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:trip_data) do
          {
            title: 'Trip Without Dates',
            description: 'A flexible trip without fixed dates'
          }
        end

        run_test!
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }

        let(:trip_data) do
          {
            title: '',
            description: 'A trip with no title'
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
        let(:trip_data) do
          {
            title: 'Test Trip',
            start_date: '2024-12-20',
            end_date: '2024-12-27'
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Trip ID'

    get 'Get trip details' do
      tags 'Trips'
      description 'Get details of a specific trip'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Trip retrieved successfully' do
        schema type: :object,
          properties: {
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: { type: :string },
                start_date: {
                  type: :string,
                  format: :date
                },
                end_date: {
                  type: :string,
                  format: :date
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:id) { trip.id }

        run_test!
      end

      response '404', 'Trip not found' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Trip not found'
            }
          }

        let(:id) { 999999 }

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
        let(:id) { trip.id }

        run_test!
      end
    end

    patch 'Update trip' do
      tags 'Trips'
      description 'Update a specific trip'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :trip_data, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string,
            example: 'Updated Trip Title'
          },
          description: {
            type: :string,
            example: 'Updated description'
          },
          start_date: {
            type: :string,
            format: :date,
            example: '2024-08-01'
          },
          end_date: {
            type: :string,
            format: :date,
            example: '2024-08-07'
          }
        }
      }

      response '200', 'Trip updated successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip updated successfully'
            },
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: { type: :string },
                start_date: {
                  type: :string,
                  format: :date
                },
                end_date: {
                  type: :string,
                  format: :date
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:id) { trip.id }
        let(:trip_data) do
          {
            title: 'Updated Summer Vacation',
            description: 'An updated relaxing trip to the beach'
          }
        end

        run_test!
      end

      response '422', 'Validation errors' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }

        let(:id) { trip.id }
        let(:trip_data) do
          {
            title: '',
            end_date: '2024-06-01' # before start date
          }
        end

        run_test!
      end

      response '404', 'Trip not found' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Trip not found'
            }
          }

        let(:id) { 999999 }
        let(:trip_data) do
          {
            title: 'Updated Title'
          }
        end

        run_test!
      end
    end

    put 'Replace trip (PUT)' do
      tags 'Trips'
      description 'Replace a specific trip entirely (full replacement)'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :trip_data, in: :body, schema: {
        type: :object,
        properties: {
          title: {
            type: :string,
            example: 'Updated Trip Title'
          },
          description: {
            type: :string,
            example: 'Updated description'
          },
          start_date: {
            type: :string,
            format: :date,
            example: '2024-08-01'
          },
          end_date: {
            type: :string,
            format: :date,
            example: '2024-08-07'
          }
        }
      }

      response '200', 'Trip replaced successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip replaced successfully'
            },
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: {
                  type: :string,
                  nullable: true
                },
                start_date: {
                  type: :string,
                  format: :date,
                  nullable: true
                },
                end_date: {
                  type: :string,
                  format: :date,
                  nullable: true
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:id) { trip.id }
        let(:trip_data) do
          {
            title: 'PUT Replaced Title'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          trip = data['trip']

          # Verify that fields not provided are cleared (null)
          expect(trip['title']).to eq('PUT Replaced Title')
          expect(trip['description']).to be_nil
          expect(trip['start_date']).to be_nil
          expect(trip['end_date']).to be_nil
        end
      end

      response '200', 'Trip replaced with all fields' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip replaced successfully'
            },
            trip: {
              type: :object,
              properties: {
                id: { type: :integer },
                title: { type: :string },
                description: { type: :string },
                start_date: {
                  type: :string,
                  format: :date
                },
                end_date: {
                  type: :string,
                  format: :date
                },
                created_at: {
                  type: :string,
                  format: :datetime
                },
                updated_at: {
                  type: :string,
                  format: :datetime
                }
              }
            }
          }

        let(:id) { trip.id }
        let(:trip_data) do
          {
            title: 'PUT Complete Replacement',
            description: 'New description',
            start_date: '2025-01-01',
            end_date: '2025-01-07'
          }
        end

        run_test!
      end
    end

    delete 'Delete trip' do
      tags 'Trips'
      description 'Delete a specific trip'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Trip deleted successfully' do
        schema type: :object,
          properties: {
            message: {
              type: :string,
              example: 'Trip deleted successfully'
            }
          }

        let(:id) { trip.id }

        run_test!
      end

      response '404', 'Trip not found' do
        schema type: :object,
          properties: {
            error: {
              type: :string,
              example: 'Trip not found'
            }
          }

        let(:id) { 999999 }

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
        let(:id) { trip.id }

        run_test!
      end
    end
  end
end