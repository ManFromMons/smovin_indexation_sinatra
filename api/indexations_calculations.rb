# frozen_string_literal: true

require 'date'
require_relative 'helpers/date_calculations'

# Provides indexation calculations
module IndexationCalculations
  include DateCalculations

  def self.calculate_new_rent(start_date, signed_on, base_rent, target_date, &health_index)
    index_calculator = IndexCalculator.new
    new_rent, base_index, current_index = index_calculator.perform(start_date, signed_on, base_rent,
                                                                   target_date, &health_index)

    [new_rent, base_index, current_index]
  end

  # Private encapsulation of the functions
  class IndexCalculator
    def perform(start_date, signed_on, base_rent, current_date, &health_index)
      calculate_new_rent(start_date, signed_on, base_rent, current_date, &health_index)
    end

    private

    def calculate_new_rent(start_date, signed_on, base_rent, current_date, &health_index)
      base_month = DateCalculations.a_month_before signed_on
      base_year = DateCalculations.get_appropriate_year base_month
      current_month = DateCalculations.the_birthday_of start_date, current_date

      base_index = health_index.call(base_month, base_year)
      current_index = health_index.call(current_month, base_year)

      new_rent = perform_indexation base_rent, current_index, base_index
      [new_rent, base_index, current_index]
    end

    def perform_indexation(base_rent, current_index, base_index)
      ((base_rent * current_index) / base_index).round(2)
    end
  end
end
