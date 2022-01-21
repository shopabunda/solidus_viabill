# frozen_string_literal: true

module SolidusViabill
  module Api
    class CheckoutController < ::Spree::BaseController
      include Spree::Core::ControllerHelpers::Order
      include SolidusViabill::Api::CheckoutHelper

      before_action :load_order

      def authorize
        payment_method_id = params[:payment_method_id]
        request_body = build_checkout_request_body(@order, payment_method_id)
        respond_to do |format|
          format.json { render json: { body: request_body } }
        end
      end

      def success
        payment_method_id = params[:payment_method_id]
        payment_params = build_payment_params(@order, 'APPROVED', payment_method_id)
        @payment = Spree::PaymentCreate.new(@order, payment_params).build
        @payment.save!
        @order.next!

        redirect_to '/checkout/confirm'
      end

      def callback; end

      private

      def load_order
        @order = current_order
      end
    end
  end
end
