# frozen_string_literal: true

# Provides access to Parameters for the APIs
module IndexationsParameters
  def indexations_api_params(request_body)
    parameters = JSON.parse(request_body.read)
    required_params = %w[start_date signed_on base_rent region]
    all_params = %w[start_date signed_on current_date base_rent region]

    missing_parameters = required_params - parameters.keys

    raise "Parameter #{missing_parameters.first} missing" unless missing_parameters.empty?
    raise "Unpermitted parameter #{(parameters.keys - all_params).first}" unless (parameters.keys - all_params).empty?

    parameters
  end
end
