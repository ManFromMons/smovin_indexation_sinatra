# frozen_string_literal: true

# Performs Date calculations
module DateCalculations
  def self.the_birthday_of(contract_date, the_date)
    base_date = Date.new(the_date.year, contract_date.month, contract_date.day)
    a_year_before a_month_before base_date
  end

  def self.get_appropriate_year(the_date)
    years = [1998, 1996, 2004, 2013]

    years.select { |year| year <= the_date.year }.max
  end

  def self.a_year_before(a_date)
    a_date.prev_year
  end

  def self.a_month_before(a_date)
    a_date.prev_month
  end
end
