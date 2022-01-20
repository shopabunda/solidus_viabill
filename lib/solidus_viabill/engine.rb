# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusViabill
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_viabill'

    initializer "solidus_viabill.add_static_preference", after: "spree.register.payment_methods" do |app|
      Spree::Config.static_model_preferences.add(
        SolidusViabill::ViabillPaymentMethod,
        'viabill_credentials', {}
      )

      app.config.spree.payment_methods << SolidusViabill::ViabillPaymentMethod
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
