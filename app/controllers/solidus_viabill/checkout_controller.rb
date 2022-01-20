# frozen_string_literal: true

module SolidusViabill
  class CheckoutController < ::Spree::BaseController
    include Spree::Core::ControllerHelpers::Order
    include SolidusViabill::CheckoutHelper

    before_action :load_order

    def authorize
    end

    def success
    end

    def callback
    end

    private

    def load_order
      @order = current_order
    end
  end
end
