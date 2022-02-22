# frozen_string_literal: true

module SolidusViabill
  module Api
    class CheckoutController < ::Spree::BaseController
      include Spree::Core::ControllerHelpers::Order
      include SolidusViabill::Api::CheckoutHelper

      skip_before_action :verify_authenticity_token
      before_action :load_order, only: %i[authorize success]

      def authorize
        payment_method_id = params[:payment_method_id]
        frontend = params[:frontend]
        request_body = build_checkout_request_body(@order, payment_method_id, frontend)
        respond_to do |format|
          format.json { render json: { body: request_body } }
        end
      end

      def success
        payment_method_id = params[:payment_method_id]
        frontend = params[:frontend]
        payment_params = build_payment_params(@order, 'APPROVED', payment_method_id)
        @payment = Spree::PaymentCreate.new(@order, payment_params).build
        @payment.save!
        @order.next!

        redirect_url = fetch_redirect_url(frontend)
        redirect_to redirect_url
      end

      def callback
        render json: {}, status: :ok
      end

      private

      def load_order
        @order = current_order || Spree::Order.find_by(number: params[:order_number])
      end

      def fetch_redirect_url(frontend)
        frontend == 'true' ? '/checkout/confirm' : "/admin/orders/#{@order.number}/confirm"
      end
    end
  end
end
