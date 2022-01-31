require 'spec_helper'

RSpec.describe SolidusViabill::Api::CheckoutHelper, type: :helper do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
  let(:payment_method) { create(:viabill_payment_method) }

  describe '#build_checkout_request_body' do
    subject(:checkout_body) { build_checkout_request_body(order, payment_method.id) }

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

    it 'has all keys' do
      expect(checkout_body.keys).to eq key_list
    end

    it 'has all keys in customParams' do
      expect(checkout_body[:customParams].keys).to eq custom_param_key_list
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
        payment_method.preferences[:viabill_secret_key],
        '#'
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
