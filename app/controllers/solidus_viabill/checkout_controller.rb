# frozen_string_literal: true

module SolidusViabill
  class CheckoutController < ::Spree::BaseController
    include Spree::Core::ControllerHelpers::Order
    include SolidusViabill::CheckoutHelper

    before_action :load_order

    def authorize
      request_body = build_checkout_request_body(@order)
      respond_to do |format|
        format.json { render json: { body: request_body } }
      end
    end

    def success
      payment_params = build_payment_params(@order, 'APPROVED')
      @payment = Spree::PaymentCreate.new(@order, payment_params).build
      @order.next! if @payment.save

      redirect_to '/checkout/confirm'
    end

    def callback; end

    private

    def load_order
      @order = current_order
    end
  end
end
