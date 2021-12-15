# == Schema Information
#
# Table name: personal_guarantees
#
#  id          :bigint           not null, primary key
#  order_id    :bigint           not null
#  contact_id  :bigint           not null
#  accepted_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :personal_guarantee do
    transient do
      customer { create(:customer) }
    end
    order { create(:order, customer: customer) }
    contact { create(:contact, customer: customer) }
  end
end
