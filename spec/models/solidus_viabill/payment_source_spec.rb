require 'spec_helper'

RSpec.describe SolidusViabill::PaymentSource, type: :model do
  let(:column_list) {
    [
      'id',
      'transaction_number',
      'order_number',
      'amount',
      'currency',
      'status',
      'time',
      'signature',
      'payment_method_id',
      'created_at',
      'updated_at'
    ]
  }

  describe 'Check Model Integrity' do
    it 'has correct table name' do
      expect(described_class.table_name).to eq 'solidus_viabill_payment_sources'
    end

    it 'has correct attributes' do
      expect(described_class.new.attributes.keys).to eq column_list
    end
  end
end
