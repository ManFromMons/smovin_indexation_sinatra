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
      status 500 if e.is_a? Net::HTTPError
      status 400
      {
        error: e.to_s
      }.to_json
    end
  end
  # rubocop:enable Lint/ShadowedException
end
