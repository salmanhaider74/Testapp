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
class OrderItem < ApplicationRecord
  include Numerify

  belongs_to :order, inverse_of: :order_items
  validates :name, :description, :unit_price, :quantity, presence: true
  monetize :unit_price_cents

  validates_presence_of :order

  def amount
    (unit_price * quantity)
  end

  def formatted_amount
    summary_amount.format
  end

  def formatted_unit_price
    summary_unit_price.format
  end

  def summary_amount
    (((unit_price * quantity) / order.amount) * order.payment)
  end

  def summary_unit_price
    (summary_amount / quantity)
  end
end
