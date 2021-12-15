# == Schema Information
#
# Table name: invoice_items
#
#  id                       :bigint           not null, primary key
#  invoice_id               :bigint           not null
#  payment_schedule_item_id :bigint           not null
#  transaction_id           :bigint
#  order_item_id            :bigint
#  name                     :string
#  description              :string
#  amount_cents             :integer          default(0), not null
#  amount_currency          :string           default("USD"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  number                   :string
#  amount_charged_cents     :integer          default(0), not null
#  amount_charged_currency  :string           default("USD"), not null
#
FactoryBot.define do
  factory :invoice_item do
    sequence(:name, 1000) { |n| "Person#{n}" }
    sequence(:description) { |n| "Description InvoiceItem#{n}" }
    amount { 2000.step(by: 2000, to: 500_000).to_a.sample }
    invoice
    payment_schedule_item
    my_transaction
    order_item
  end
end
