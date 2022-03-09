# frozen_string_literal: true

module SolidusViabill
  module Api
    module CheckoutHelper
      VIABILL_PROTOCOL = '3.1'
      VIABILL_STATUS = %w[CANCELLED APPROVED REJECTED].freeze
      def build_checkout_request_body(order, payment_method_id, frontend)
        payment_method = Spree::PaymentMethod.find_by(id: payment_method_id)
        gateway = SolidusViabill::Gateway.new(payment_method.preferences)
        success_url_params = "?payment_method_id=#{payment_method_id}&frontend=#{frontend}&order_number=#{order.number}"
        request_body = {
          protocol: VIABILL_PROTOCOL,
          transaction: order.number,
          amount: order.outstanding_balance.to_s,
          currency: order.currency,
          test: gateway.test_env.to_s,
          md5check: '',
          sha256check: '',
          apikey: gateway.api_key,
          order_number: order.number,
          success_url: "#{gateway.success_url}#{success_url_params}",
          cancel_url: gateway.cancel_url,
          callback_url: gateway.callback_url,
          customParams: {
            email: order.email,
            phoneNumber: order.bill_address&.phone,
            fullName: order.bill_address.name,
            address: [order.bill_address.address1, order.bill_address.address2].join(', '),
            city: order.bill_address.city,
            postalCode: order.bill_address.zipcode,
            country: order.bill_address.country.name
          }
        }
        request_body[:sha256check] = gateway.generate_signature(
          gateway.api_key,
          request_body[:amount],
          request_body[:currency],
          request_body[:transaction],
          request_body[:order_number],
          gateway.success_url,
          gateway.cancel_url,
          gateway.secret_key
        )
        request_body
      end

      def build_payment_params(order, status, payment_method_id)
        raise 'Unverified Status for Payment' unless VIABILL_STATUS.include? status

        payment_method = Spree::PaymentMethod.find_by(id: payment_method_id)
        gateway = SolidusViabill::Gateway.new(payment_method.preferences)
        request_body = {
          amount: order.outstanding_balance.to_s,
          payment_method_id: payment_method_id,
          source_attributes: {
            transaction_number: order.number,
            order_number: order.number,
            amount: order.outstanding_balance.to_s,
            currency: order.currency,
            status: status,
            time: Time.now.to_i,
            signature: ''
          }
        }
        request_body[:source_attributes][:signature] = gateway.generate_signature(
          request_body[:source_attributes][:transaction_number],
          request_body[:source_attributes][:amount],
          request_body[:source_attributes][:currency],
          request_body[:source_attributes][:order_number],
          request_body[:source_attributes][:status],
          request_body[:source_attributes][:time],
          gateway.secret_key
        )
        request_body
      end
    end
  end
end
