# frozen_string_literal: true

# Provides validators for the Calculator
module IndexationsValidators
  # rubocop:disable Metrics/MethodLength
  def self.valid?(json_data)
    start_date = json_data['start_date']
    signed_on = json_data['signed_on']
    current_date = json_data.key?('current_date') && !json_data['current_date'].blank? ? json_data['current_date'] : Date.today.strftime('%Y-%m-%d')
    base_rent = json_data['base_rent']
    region = json_data['region']

    validation_actions = ValidationActions.new

    has_error, error_details = validation_actions.perform start_date, signed_on, current_date, base_rent, region

    return [true, error_details] if has_error

    [false, { start_date: Date.parse(start_date), signed_on: Date.parse(signed_on),
              current_date: Date.parse(current_date), base_rent: Float(base_rent),
              region: }]
  end

  # rubocop:enable Metrics/MethodLength

  # Private modularisation of validation functions
  class ValidationActions
    def perform(start_date, signed_on, current_date, base_rent, region)
      error_collection = {
        start_date: validate_date(start_date),
        signed_on: validate_date(signed_on),
        current_date: validate_date(current_date),
        base_rent: validate_base_rent(base_rent),
        region: validate_region(region)
      }

      has_error = error_collection.any? { |_, errors| errors.any? }

      [has_error, error_collection]
    end

    private

    def validate_date(date)
      errors = []
      errors << 'missing' if date.blank?
      errors << 'invalid' unless date_valid?(date)
      errors << 'must_be_in_the_past' if Date.parse(date) > Date.today
      errors
    end

    def date_valid?(date)
      Date.parse(date)
      true
    rescue StandardError
      false
    end

    def validate_base_rent(base_rent)
      errors = []
      errors << 'missing' if base_rent.blank?
      errors << 'invalid' unless number?(base_rent)
      errors << 'must_be_positive' unless base_rent.to_i.positive?
      errors
    end

    def validate_region(region)
      errors = []
      errors << 'missing' if region.blank?
      errors << 'invalid' unless %w[brussels flanders wallonia].include?(region.downcase)
      errors
    end

    def number?(input)
      Float(input)
      true
    rescue ArgumentError
      false
    end
  end
end
