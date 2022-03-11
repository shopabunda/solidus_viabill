require 'spec_helper'

RSpec.describe SolidusViabill::Api::CheckoutHelper, type: :helper do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
  let(:payment_method) { create(:viabill_payment_method) }

  describe '#build_checkout_request_body' do
    subject(:checkout_body) { build_checkout_request_body(order, payment_method.id, frontend) }

    let(:result) do
      {
        amount: "0.0",
        apikey: "apikey",
        callback_url: "https://example.com/api/checkout_callback",
        cancel_url: "https://example.com/checkout/payment",
        currency: "USD",
        customParams: {
          address: "A Different Road, Northwest",
          city: "Herndon",
          country: "United States",
          email: order.email,
          fullName: "John Von Doe",
          phoneNumber: "555-555-0199",
          postalCode: order.bill_address.zipcode
        },
        md5check: "",
        order_number: order.number,
        protocol: "3.1",
        sha256check: "sha256check",
        success_url: "https://example.com/api/checkout_success?payment_method_id=#{payment_method.id}&frontend=#{frontend}&order_number=#{order.number}",
        test: "true",
        transaction: order.number,
      }
    end
    let(:key_list) {
      [
        :protocol,
        :transaction,
        :amount,
        :currency,
        :test,
        :md5check,
        :sha256check,
        :apikey,
        :order_number,
        :success_url,
        :cancel_url,
        :callback_url,
        :customParams
      ]
    }
    let(:custom_param_key_list) {
      [
        :email,
        :phoneNumber,
        :fullName,
        :address,
        :city,
        :postalCode,
        :country
      ]
    }

    # rubocop:disable RSpec/AnyInstance
    before { allow_any_instance_of(SolidusViabill::Gateway).to receive(:generate_signature).and_return('sha256check') }
    # rubocop:enable RSpec/AnyInstance

    context 'when frontend is true' do
      let(:frontend) { true }

      it 'has all keys' do
        expect(checkout_body.keys).to eq key_list
      end

      it 'has all keys in customParams' do
        expect(checkout_body[:customParams].keys).to eq custom_param_key_list
      end

      it 'builds a request body' do
        expect(checkout_body).to eq(result)
      end
    end

    context 'when frontend is false' do
      let(:frontend) { false }

      it 'has all keys' do
        expect(checkout_body.keys).to eq key_list
      end

      it 'has all keys in customParams' do
        expect(checkout_body[:customParams].keys).to eq custom_param_key_list
      end

      it 'builds a request body' do
        expect(checkout_body).to eq(result)
      end
    end
  end

  describe '#build_payment_params' do
    subject(:payment_params) { build_payment_params(order, 'APPROVED', payment_method.id) }

    let(:gateway) { SolidusViabill::Gateway.new }
    let(:key_list) {
      [
        :amount,
        :payment_method_id,
        :source_attributes
      ]
    }

    let(:source_attribute_keys) {
      [
        :transaction_number,
        :order_number,
        :amount,
        :currency,
        :status,
        :time,
        :signature
      ]
    }

    it 'has all keys' do
      expect(payment_params.keys).to eq key_list
    end

    it 'has all keys in source_attributes' do
      expect(payment_params[:source_attributes].keys).to eq source_attribute_keys
    end

    it 'has correct signature' do
      expect(
        payment_params[:source_attributes][:signature]
      ).to eq gateway.generate_signature(
        order.number,
        order.outstanding_balance.to_s,
        order.currency,
        order.number,
        'APPROVED',
        Time.now.to_i,
        payment_method.preferences[:viabill_secret_key]
      )
    end

    it 'does not raise error for status "APPROVED"' do
      expect{
        build_payment_params(order, 'APPROVED', payment_method.id)
      }.not_to raise_error RuntimeError
    end

    it 'does not raise error for status "CANCELLED"' do
      expect{
        build_payment_params(order, 'CANCELLED', payment_method.id)
      }.not_to raise_error RuntimeError
    end

    it 'does not raise error for status "REJECTED"' do
      expect{
        build_payment_params(order, 'REJECTED', payment_method.id)
      }.not_to raise_error RuntimeError
    end

    it 'raises error for unrecognised status' do
      expect{
        build_payment_params(order, 'FAILED', payment_method.id)
      }.to raise_error RuntimeError
    end

    it 'raises error for empty status' do
      expect{
        build_payment_params(order, ' ', payment_method.id)
      }.to raise_error RuntimeError
    end

    it 'raises error for nil status' do
      expect{
        build_payment_params(order, nil, payment_method.id)
      }.to raise_error RuntimeError
    end
  end
end
