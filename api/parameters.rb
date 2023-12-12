# frozen_string_literal: true

# Provides access to Parameters for the APIs
module Parameters
  def self.indexations_api_params(json_parameters)
    parameters = json_parameters.keys
    required_params = %w[start_date signed_on base_rent region]
    all_params = %w[start_date signed_on current_date base_rent region]

    raise "Parameter #{(required_params - parameters).first} missing" unless (required_params - parameters).empty?
    raise "Unpermitted parameter #{(parameters - all_params).first}" unless (parameters - all_params).empty?

    json_parameters
  end
end
