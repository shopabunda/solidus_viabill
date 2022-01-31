# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusViabill
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_viabill'

    initializer "solidus_viabill.add_static_preference", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusViabill::ViabillPaymentMethod
      Spree::Config.static_model_preferences.add(
        SolidusViabill::ViabillPaymentMethod,
        'viabill_credentials', {
          viabill_api_key: ENV['VIABILL_API_KEY'],
          viabill_secret_key: ENV['VIABILL_SECRET_KEY'],
          viabill_success_url: ENV['VIABILL_SUCCESS_URL'],
          viabill_cancel_url: ENV['VIABILL_CANCEL_URL'],
          viabill_callback_url: ENV['VIABILL_CALLBACK_URL'],
          viabill_test_env: ENV['VIABILL_TEST_ENV']
        }
      )
      Spree::PermittedAttributes.source_attributes.concat [
        :transaction_number,
        :order_number,
        :amount,
        :currency,
        :status,
        :time,
        :signature
      ]
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
