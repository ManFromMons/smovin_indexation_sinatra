# frozen_string_literal: true
require 'i18n'
require 'sinatra'
require 'json'
require 'net/http'

require_relative 'front_end/helpers/locale'
require_relative 'front_end/helpers/i18n_macros'
# Provides a Front-End to the API
class IndexationFrontEnd < Sinatra::Base
  include Locale
  include I18nMacros

  configure do
    set :dump_errors, true
    set :raise_errors, true
    set :root, './front_end/'
    I18n.load_path += Dir["#{File.expand_path('front_end/i18n')}/*.yml"]
    I18n.available_locales = %i[en fr de nl]
  end

  ['/:locale?'].each do |path|
    before path do
      assign_request_locale
    end
  end

  before do
    # assign_request_locale
  end

  get '/:locale?' do
    erb :index
  end
end
