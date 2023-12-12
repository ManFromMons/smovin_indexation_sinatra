# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'net/http'
require 'rack/cors'

require_relative 'api/providers/indexations_health_index'
require_relative 'api/validations'
require_relative 'api/parameters'
require_relative 'api/indexations_calculations'

# API to calculate rent api
class IndexationAPI < Sinatra::Base
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
      request_body = Parameters.indexations_api_params(JSON.parse(request.body.read))
      validation_failed, data_details = IndexationsValidators.valid?(request_body)

      if validation_failed
        status 400
        data_details.to_json
        break
      end

      new_rent, base_index, current_index = generate_answer(data_details)

      status 200
      { new_rent:, base_index:, current_index: }.to_json
    rescue Net::HTTPError, JSON::ParserError, StandardError => e
      status 500 if e.is_a? Net::HTTPError
      status 400
      {
        error: e.to_s
      }.to_json
    end
  end
  # rubocop:enable Lint/ShadowedException

  private

  def generate_answer(data_details)
    http_proc = proc { |target_date, base_year|
      IndexationsHealthIndex.get_health_index(base_year, target_date)
    }

    new_rent, base_index, current_index = IndexationCalculations.calculate_new_rent(
      data_details[:start_date], data_details[:signed_on],
      data_details[:base_rent], data_details[:current_date],
      &http_proc
    )

    [new_rent, base_index, current_index]
  end
end
