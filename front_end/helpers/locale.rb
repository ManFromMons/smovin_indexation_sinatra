# frozen_string_literal: true

# Provides assistance for locale operations and i18n
module Locale
  def preferred_language_from_request(request, available, default)
    preferred = request.env['HTTP_ACCEPT_LANGUAGE'].split(',').map(&:strip).first.split('-').first.to_sym
    return preferred if available.include?(preferred)

    default
  end

  def assign_request_locale
    I18n.locale = params[:locale] ||
                  preferred_language_from_request(request, I18n.available_locales, :en)
  end
end
