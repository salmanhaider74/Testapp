# == Schema Information
#
# Table name: order_items
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint           not null
#  name                :string           not null
#  description         :string           not null
#  quantity            :integer          not null
#  unit_price_cents    :integer          default(0), not null
#  unit_price_currency :string           default("USD"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  number              :string
#
FactoryBot.define do
  factory :order_item do
    order { create(:order) }
    sequence(:name) { |n| "Order Item#{n}" }
    sequence(:description) { |n| "Description Order Item#{n}" }
    quantity { [1, 2, 3, 4, 5].sample }
    unit_price { 5000.step(by: 5000, to: 500_000).to_a.sample }
  end
end
