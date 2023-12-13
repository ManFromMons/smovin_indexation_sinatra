# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:default)

require 'rack/unreloader'

require "#{File.dirname(__FILE__)}/indexation_frontend.rb"
require "#{File.dirname(__FILE__)}/indexation_api.rb"

map '/' do
  fe_reloader = Rack::Unreloader.new { IndexationFrontEnd }
  fe_reloader.require("#{File.dirname(__FILE__)}/indexation_frontend.rb")
  fe_reloader.require 'front_end/**/*.rb'

  set :public_folder, 'public'
  run fe_reloader
end

map '/api/v1' do
  api_reloader = Rack::Unreloader.new { IndexationAPI }
  api_reloader.require("#{File.dirname(__FILE__)}/indexation_api.rb")
  api_reloader.require 'api/**/*.rb'

  run api_reloader
end
