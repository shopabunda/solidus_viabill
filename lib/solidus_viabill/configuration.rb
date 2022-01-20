# frozen_string_literal: true

module SolidusViabill
  class Configuration
    # Define here the settings for this extension, e.g.:
    #
    attr_accessor :viabill_api_key, :viabill_secret_key, :viabill_success_url, :viabill_cancel_url,
      :viabill_callback_url, :viabill_test_env
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
