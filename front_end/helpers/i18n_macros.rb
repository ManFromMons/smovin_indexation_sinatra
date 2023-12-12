# frozen_string_literal: true

# Provides I18n helper functions for views
module I18nMacros
  def t(key)
    I18n.t(key)
  end
end
