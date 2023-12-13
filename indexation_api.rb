# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'net/http'
require 'rack/cors'

require_relative 'api/exceptions/validation_exception'
require_relative 'api/handlers/indexations_request_handler'

# API to calculate rent api
class IndexationAPI < Sinatra::Base
  include IndexationsRequestHandler
  def filter_backtrace(backtrace)
    app_path = File.expand_path(__dir__) # Path to your application's directory

    backtrace.select do |line|
      file_path = line.split(':').first # Extracting the file path from the backtrace line
      File.realpath(file_path).start_with?(app_path) # Check if the file path is within your app's directory
    end
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '/', headers: :any, methods: %i[get]
      resource '/indexations', headers: :any, methods: %i[get post]
    end
  end

  get '/' do
    { Welcome: 'Hello from IndexationAPI' }.to_json
  end

  # rubocop:disable Lint/ShadowedException
  post '/indexations' do
    content_type :json

    begin
      status 200
      process_indexations_post_request request
    rescue ValidationException => e
      status 400
      e.error_collection.to_json
    rescue Net::HTTPError, JSON::ParserError, StandardError => e
      $stdout << "#{e.message}\n#{(filter_backtrace e.backtrace).join('\n')}"
      status 500 if e.is_a? Net::HTTPError
      status 400
      {
        error: e.to_s
      }.to_json
    end
  end
  # rubocop:enable Lint/ShadowedException
end
