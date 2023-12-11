# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'net/http'
require 'rack/cors'

require './api/indexation_http'
require './api/date_calculations'
require './api/calculations'
require './api/validations'

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
      request_body = api_params(JSON.parse(request.body.read))
      validation_failed, data_details = Validations.valid?(request_body)

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

  def api_params(json_parameters)
    parameters = json_parameters.keys
    required_params = %w[start_date signed_on base_rent region]
    all_params = %w[start_date signed_on current_date base_rent region]

    raise "Parameter #{(required_params - parameters).first} missing" unless (required_params - parameters).empty?
    raise "Unpermitted parameter #{(parameters - all_params).first}" unless (parameters - all_params).empty?

    json_parameters
  end

  def generate_answer(data_details)
    http_proc = proc { |target_date, base_year|
      IndexationHTTP.get_health_index(base_year, target_date)
    }

    new_rent, base_index, current_index = IndexationCalculations.calculate_new_rent(
      data_details[:start_date], data_details[:signed_on],
      data_details[:base_rent], data_details[:current_date],
      &http_proc
    )

    [new_rent, base_index, current_index]
  end
end
