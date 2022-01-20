class CreateSolidusViabillPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_viabill_payment_sources do |t|
      t.string :transaction_number
      t.string :order_number
      t.string :amount
      t.string :currency
      t.string :status
      t.string :time
      t.string :signature
      t.integer :payment_method_id
      t.timestamps
    end
  end
end
