require 'spec_helper'
require 'net/http'

RSpec.describe SolidusViabill::Gateway, type: :model do
  let(:gateway) { described_class.new }
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
  let(:payment_method) { create(:viabill_payment_method) }
  let(:payment_source) {
    create(
      :viabill_payment_source,
      payment_method_id: payment_method.id,
      order_number: order.number
    )
  }
  let(:payment) {
    create(
      :payment,
      order: order,
      amount: order.outstanding_balance + 100, # adding 100 to pass "Amount is greater than the allowed amount" error
      source_type: "SolidusViabill::PaymentSource",
      source_id: payment_source.id,
      payment_method_id: payment_method.id
    )
  }
  let(:refund) { create(:refund, payment: payment) }

  describe '#initialize' do
    it 'initializes without any arguments' do
      expect(described_class.new.class).to eq described_class
    end

    it 'initializes with arguments' do
      expect(
        described_class.new('payments', 1000, { success: true }).class
      ).to eq described_class
    end
  end

  describe '#generate signature' do
    it 'generates the correct signature' do
      expect(
        gateway.generate_signature('Batman Begins', 'Dark Knight', 'Dark Knight Rises', '#')
      ).to eq '52243a4cfc033e15700abdd78184d9e198d0956be71e0d9befe7044408d2bfb8'
    end

    it 'raises error with no Arguments' do
      expect { gateway.generate_signature }.to raise_error ArgumentError
    end
  end

  describe '#authorize' do
    subject(:authorize_response) { gateway.authorize(100, payment_source, {}) }

    it 'successfully returns a response' do
      expect(authorize_response.class).to eq ActiveMerchant::Billing::Response
    end
  end

  describe '#capture' do
    subject(:capture_response) { gateway.capture(100, order.number, { originator: payment, currency: 'USD' }) }

    before do
      order.update(state: 'complete')
      payment.update(state: 'pending')
      response = Net::HTTPNoContent.new('', '204', 'NoContent')
      allow(gateway).to receive(:send_post_request).and_return(response)
    end

    it 'successfully returns a response' do
      expect(capture_response.class).to eq ActiveMerchant::Billing::Response
    end
  end

  describe '#purchase' do
    subject(:purchase_response) { gateway.purchase(100, payment_source, { originator: payment, currency: 'USD' }) }

    before do
      response = Net::HTTPNoContent.new('', '204', 'NoContent')
      allow(gateway).to receive(:send_post_request).and_return(response)
    end

    it 'successfully returns a response' do
      expect(purchase_response.class).to eq ActiveMerchant::Billing::Response
    end
  end

  describe '#void' do
    subject(:void_response) { gateway.void(order.number, { originator: payment, currency: 'USD' }) }

    before do
      response = Net::HTTPNoContent.new('', '204', 'NoContent')
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:send_post_request).and_return(response)
      # rubocop:enable RSpec/AnyInstance
    end

    it 'successfully returns a response' do
      expect(void_response.class).to eq ActiveMerchant::Billing::Response
    end

    it 'successfully updates source' do
      void_response
      payment_source.reload
      expect(payment_source.status).to eq 'CANCELED'
    end
  end

  describe '#credit' do
    subject(:credit_response) { gateway.credit(100, order.number, { originator: refund, currency: 'USD' }) }

    before do
      response = Net::HTTPNoContent.new('', '204', 'NoContent')
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(:send_post_request).and_return(response)
      # rubocop:enable RSpec/AnyInstance
    end

    it 'successfully returns a response' do
      expect(credit_response.class).to eq ActiveMerchant::Billing::Response
    end

    it 'successfully updates source' do
      credit_response
      payment_source.reload
      expect(payment_source.status).to eq 'REFUNDED'
    end
  end
end
