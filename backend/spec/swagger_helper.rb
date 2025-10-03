# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join('docs').to_s

  # TripTally API documentation configuration
  config.openapi_specs = {
    'api_spec.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'TripTally API',
        version: 'v1',
        description: 'API for TripTally mobile application - trip planning and management',
        contact: {
          name: 'TripTally API Support',
        },
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server',
        },
        {
          url: 'https://api.triptally.com',
          description: 'Production server',
        },
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
          },
        },
      },
    },
  }

  config.openapi_format = :yaml
end
