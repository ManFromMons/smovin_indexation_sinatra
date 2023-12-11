# frozen_string_literal: true

require 'date'
require 'net/http'

# Provides HTTP functionality for api calculations
module IndexationHTTP
  URL_ADDR = 'https://fi7661d6o4.execute-api.eu-central-1.amazonaws.com/prod/be/indexes/%s/%s-%s'

  def self.get_health_index(base_year, the_date)
    gov_data = call_service base_year, the_date

    raise "No service data for #{base_year}:#{the_date}" if gov_data.nil?

    gov_data['MS_HLTH_IDX']
  end

  def self.call_service(base_year, the_date)
    url = URI(format(URL_ADDR, base_year, the_date.year, the_date.month))

    response = Net::HTTP.get_response(url)

    return unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)['index']
  end
end
