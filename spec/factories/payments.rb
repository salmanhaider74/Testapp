# == Schema Information
#
# Table name: payments
#
#  id                :bigint           not null, primary key
#  resource_type     :string           not null
#  resource_id       :bigint           not null
#  external_id       :string
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  status            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  number            :string
#  error_message     :string
#  payment_method_id :bigint           not null
#
FactoryBot.define do
  factory :payment do
    factory :customer_payment do
      association :resource, factory: :customer_contact
      association :payment_method, factory: [:payment_method_ach, :payment_method_invoice].sample
    end

    factory :vendor_payment do
      association :resource, factory: :vendor
      association :payment_method, factory: [:payment_method_ach, :payment_method_invoice].sample
    end

    amount { 9.99 }
    status { %w[processed error].sample }
    external_id { 1 }
  end
end
