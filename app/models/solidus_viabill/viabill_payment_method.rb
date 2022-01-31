# frozen_string_literal: true

module SolidusViabill
  class ViabillPaymentMethod < SolidusSupport.payment_method_parent_class
    preference :viabill_api_key, :string
    preference :viabill_secret_key, :string
    preference :viabill_success_url, :string
    preference :viabill_cancel_url, :string
    preference :viabill_callback_url, :string
    preference :viabill_test_env, :boolean

    def gateway_class
      ::SolidusViabill::Gateway
    end

    def payment_source_class
      ::SolidusViabill::PaymentSource
    end

    def partial_name
      "viabill"
    end
  end
end
