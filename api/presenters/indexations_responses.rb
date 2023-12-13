# frozen_string_literal: true

# Provides response formatting
module IndexationsResponse
  def present_indexations_response(new_rent, base_index, current_index)
    { new_rent:, base_index:, current_index: }.to_json
  end
end
