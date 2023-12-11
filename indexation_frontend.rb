# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'net/http'

# Provides a Front-End to the API
class IndexationFrontEnd < Sinatra::Base
  def assign_request_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      preferred_language = request.env['HTTP_ACCEPT_LANGUAGE'].split(',').map(&:strip).first
      preferred_language = preferred_language.split('-').first
      I18n.locale = preferred_language.to_sym if I18n.locale_available?(preferred_language)
      I18n.locale = I18n.default_locale unless I18n.locale_available?(preferred_language)
    end
  end

  helpers do
    def t(key)
      I18n.t(key)
    end
  end

  configure do
    set :dump_errors, true
    set :raise_errors, true
    set :root, './front_end/'
    I18n.load_path += Dir["#{File.expand_path('front_end/i18n')}/*.yml"]
    I18n.available_locales = %i[en fr de nl]
  end

  get '/:locale?' do
    assign_request_locale
    erb :index
  end
end
