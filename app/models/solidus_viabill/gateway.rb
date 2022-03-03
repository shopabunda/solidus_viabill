# frozen_string_literal: true

require 'uri'
require 'net/http'

module SolidusViabill
  class Gateway
    include SolidusViabill

    attr_reader :api_key, :secret_key

    def initialize(options = {})
      @api_key =    options[:viabill_api_key]
      @secret_key = options[:viabill_secret_key]
    end

    def authorize(_amount, payment_source, _gateway_options)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction approved',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def capture(float_amount, order_number, gateway_options)
      payment_source = gateway_options[:originator].source
      request_url = "#{SolidusViabill.viabill_url}/transaction/capture"
      currency = gateway_options[:currency]
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
      raise 'Viabill Server Response Error: Did not get correct response code' unless successful_response(response)

      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction captured',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def void(response_code, options)
      payment_source = options[:originator].source

      request_url = "#{SolidusViabill.viabill_url}/transaction/cancel"

      params = {
        'signature' => generate_signature(
          response_code,
          api_key,
          secret_key,
          '#'
        ),
        'id' => response_code,
        'apikey' => api_key
      }
      response = send_post_request(request_url, params)
      raise 'Viabill Server Response Error: Did not get correct response code' unless successful_response(response)

      payment_source.update(status: 'CANCELED')
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction canceled',
        payment_source.attributes,
        authorization: payment_source.order_number
      )
    end

    def purchase(float_amount, payment_source, gateway_options)
      capture(float_amount, payment_source.order_number, gateway_options)
    end

    def credit(amount, response_code, options)
      float_amount = amount / 100.0
      payment = options[:originator].payment
      currency = payment.currency
      payment_source = payment.source
      request_url = "#{SolidusViabill.viabill_url}/transaction/refund"

      params = {
        'signature' => generate_signature(
          response_code,
          api_key,
          float_amount,
          currency,
          secret_key,
          '#'
        ),
        'amount' => float_amount.to_s,
        'currency' => currency,
        'id' => response_code,
        'apikey' => api_key
      }
      response = send_post_request(request_url, params)
      raise 'Viabill Server Response Error: Did not get correct response code' unless successful_response(response)

      payment_source.update(status: 'REFUNDED')
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction refunded',
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

    def successful_response(response)
      %w[200 202 204].include?(response.code)
    end
  end
end
