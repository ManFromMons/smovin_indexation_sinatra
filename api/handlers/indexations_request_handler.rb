# frozen_string_literal: true

require_relative '../providers/indexations_health_index_provider'
require_relative '../validators/indexations_validators'
require_relative 'indexations_parameters'
require_relative '../services/indexations_calculations'
require_relative '../presenters/indexations_responses'

# Handles the API's '/indexations' POST request
module IndexationsRequestHandler
  include IndexationsParameters
  include IndexationsResponse
  include IndexationsHealthIndexProvider
  include IndexationsValidators
  include IndexationCalculations

  def process_indexations_post_request(request)
    validation_failed, input_data = valid?(indexations_api_params(request.body))

    raise ValidationException, input_data if validation_failed

    provider_proc = proc { |target_date, base_year|
      get_health_index(base_year, target_date)
    }

    new_rent, base_index, current_index = generate_answer(input_data, &provider_proc)
    present_indexations_response new_rent, base_index, current_index
  end
end
