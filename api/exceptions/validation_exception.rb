# frozen_string_literal: true

# Custom error type to raise specific Validation errors
class ValidationException < StandardError
  attr_reader :error_collection

  def initialize(error_data)
    super
    @error_collection = error_data
  end
end
