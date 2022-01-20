# frozen_string_literal: true

SolidusViabill.configure do |config|
  # TODO: Remember to change this with the actual preferences you have implemented!
  # config.sample_preference = 'sample_value'
  config.viabill_api_key = ENV.fetch('VIABILL_API_KEY', '')
  config.viabill_secret_key = ENV.fetch('VIABILL_SECRET_KEY', '')
  config.viabill_success_url = ENV.fetch('VIABILL_SUCCESS_URL', '')
  config.viabill_cancel_url = ENV.fetch('VIABILL_CANCEL_URL', '')
  config.viabill_callback_url = ENV.fetch('VIABILL_CALLBACK_URL', '')
  config.viabill_test_env = ENV.fetch('VIABILL_TEST_ENV', '')
end
