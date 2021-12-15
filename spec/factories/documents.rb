# == Schema Information
#
# Table name: documents
#
#  id                    :bigint           not null, primary key
#  customer_id           :bigint           not null
#  order_id              :bigint
#  personal_guarantee_id :bigint
#  type                  :string
#  json_data             :jsonb            not null
#
FactoryBot.define do
  factory :document do
    customer { create(:customer) }
    order { create(:order, customer: customer) }
    personal_guarantee { create(:personal_guarantee, customer: customer) }
    type { %w[fico duns financial].sample }
  end
end
