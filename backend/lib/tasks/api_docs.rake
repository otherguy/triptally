# frozen_string_literal: true

namespace :api do
  namespace :docs do
    desc "Generate OpenAPI spec and static HTML documentation"
    task generate: :environment do
      puts "🔧 Generating OpenAPI specification..."

      # Run rswag specs to generate the OpenAPI spec
      system("bundle exec rails rswag:specs:swaggerize")

      if File.exist?(Rails.root.join("docs/api_spec.yaml"))
        puts "✅ OpenAPI spec generated: docs/api_spec.yaml"

        puts "🔧 Generating static HTML documentation..."

        # Generate static HTML using redoc-cli
        system("bun run --yarn docs:generate")

        if File.exist?(Rails.root.join("docs/api.html"))
          puts "✅ Static HTML documentation generated: docs/api.html"
          puts "📖 Open docs/api.html in your browser to view the documentation"
        else
          puts "❌ Failed to generate HTML documentation"
          exit 1
        end
      else
        puts "❌ Failed to generate OpenAPI specification"
        exit 1
      end
    end

    desc "Generate only OpenAPI spec (no HTML)"
    task spec: :environment do
      puts "🔧 Generating OpenAPI specification..."
      system("bundle exec rails rswag:specs:swaggerize")

      if File.exist?(Rails.root.join("docs/api_spec.yaml"))
        puts "✅ OpenAPI spec generated: docs/api_spec.yaml"
      else
        puts "❌ Failed to generate OpenAPI specification"
        exit 1
      end
    end

    desc "Generate only static HTML from existing spec"
    task html: :environment do
      spec_file = Rails.root.join("docs/api_spec.yaml")

      unless File.exist?(spec_file)
        puts "❌ OpenAPI spec not found: #{spec_file}"
        puts "Run 'rake api:docs:spec' first to generate the specification"
        exit 1
      end

      puts "🔧 Generating static HTML documentation..."
      system("bun run --yarn docs:generate")

      if File.exist?(Rails.root.join("docs/api.html"))
        puts "✅ Static HTML documentation generated: docs/api.html"
        puts "📖 Open docs/api.html in your browser to view the documentation"
      else
        puts "❌ Failed to generate HTML documentation"
        exit 1
      end
    end

    desc "Serve documentation locally for development"
    task serve: :environment do
      spec_file = Rails.root.join("docs/api_spec.yaml")

      unless File.exist?(spec_file)
        puts "❌ OpenAPI spec not found: #{spec_file}"
        puts "Run 'rake api:docs:spec' first to generate the specification"
        exit 1
      end

      puts "🚀 Starting documentation server..."
      puts "📖 Documentation available at: http://localhost:8080"
      puts "Press Ctrl+C to stop"
      system("bun run --yarn docs:serve")
    end

    desc "Clean generated documentation files"
    task clean: :environment do
      files_to_clean = [
        Rails.root.join("docs/api_spec.yaml"),
        Rails.root.join("docs/api.html"),
      ]

      files_to_clean.each do |file|
        if File.exist?(file)
          File.delete(file)
          puts "🗑️  Deleted: #{file}"
        end
      end

      puts "✅ Documentation cleanup complete"
    end
  end
end
