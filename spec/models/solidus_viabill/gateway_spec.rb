require 'spec_helper'

RSpec.describe SolidusViabill::Gateway, type: :model do
  let(:gateway) { described_class.new }
  let(:payment_method) { create(:viabill_payment_method) }
  let(:payment_source) { create(:viabill_payment_source, payment_method_id: payment_method.id) }

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
end
