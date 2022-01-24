# frozen_string_literal: true

require 'uri'
require 'net/http'

module SolidusViabill
  class Gateway
    include SolidusViabill

    def initialize(*args); end

    def authorize(_amount, payment_source, _gateway_options)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction approved',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def capture(float_amount, order_number, gateway_options)
      api_key = SolidusViabill.config.viabill_api_key
      secret_key = SolidusViabill.config.viabill_secret_key
      request_url = "#{SolidusViabill.viabill_url}/transaction/capture"
      currency = gateway_options[:currency]
      payment_source = gateway_options[:originator].source
      raise 'Viabill Payment is not Approved' unless payment_source.status == 'APPROVED'

      capture_amount = (-float_amount.to_f / 100).to_s
      params = {
        'signature' => generate_signature(
          order_number,
          api_key,
          capture_amount,
          currency,
          secret_key,
          '#'
        ),
        'amount' => capture_amount,
        'currency' => currency,
        'id' => order_number,
        'apikey' => api_key
      }
      response = send_post_request(request_url, params)
      raise 'Viabill Server Response Error: Did not get correct response code' unless response.code == '204'

      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction captured',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def void(*args); end

    def purchase(float_amount, payment_source, gateway_options)
      capture(float_amount, payment_source.order_number, gateway_options)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction approved and captured',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def generate_signature(*args, join_character)
      base_string = args.join(join_character)
      Digest::SHA256.hexdigest(base_string)
    end

    private

    def send_post_request(url, params)
      Net::HTTP.post_form(URI.parse(url), params)
    end
  end
end
