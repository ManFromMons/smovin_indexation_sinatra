# frozen_string_literal: true

require 'net/http'
require 'uri'

# A provider of HTTP activities in the API and application as a whole
# It will provide our simple HTTP requirements
# Example usage:
# client = HTTPClient::Client.new('https://jsonplaceholder.typicode.com')
#
# GET request
# response = client.get('/posts/1')
# puts "GET Response: #{response}"
#
# POST request
# response = client.post('/posts', { title: 'foo', body: 'bar', userId: 1 }.to_json, { 'Content-Type': 'application/json' })
# puts "POST Response: #{response}"
module HTTPClient
  # A specific HTTPError exception to collate all other errors produced here
  class HTTPError < StandardError; end

  # Will be our client for HTTP Requests
  class Client
    def initialize(base_url)
      @base_url = URI.parse(base_url)
    end

    def get(path, headers = {})
      request(Net::HTTP::Get, path, headers)
    end

    def post(path, body = nil, headers = {})
      request(Net::HTTP::Post, path, headers, body)
    end

    def put(path, body = nil, headers = {})
      request(Net::HTTP::Put, path, headers, body)
    end

    def delete(path, headers = {})
      request(Net::HTTP::Delete, path, headers)
    end

    private

    def request(request_class, path, headers = {}, body = nil)
      uri = @base_url + path
      request = request_class.new(uri)

      headers.each { |key, value| request[key.to_s] = value }

      request.body = body if body

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      handle_response(response)
    end

    def handle_response(response)
      case response
      when Net::HTTPSuccess
        response.body
      else
        raise HTTPError, "HTTP Error: #{response.code} - #{response.message}"
      end
    end
  end
end
