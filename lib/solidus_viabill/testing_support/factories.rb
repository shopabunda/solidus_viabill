# frozen_string_literal: true

FactoryBot.define do
  factory :viabill_payment_source, class: SolidusViabill::PaymentSource do
    transaction_number { 'R234567' }
    order_number { 'R234567' }
    amount { '100' }
    currency { 'USD' }
    status { 'APPROVED' }
    time { Time.now.to_i.to_s }
    signature { 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' }
  end

  factory :viabill_payment_method, class: SolidusViabill::ViabillPaymentMethod do
    name { 'Viabill' }
    available_to_admin { true }
    available_to_users { true }
  end
end
