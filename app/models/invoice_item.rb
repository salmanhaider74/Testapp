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
class InvoiceItem < ApplicationRecord
  include Numerify
  monetize :amount_cents, { greater_than: 0 }
  monetize :amount_charged_cents, { greater_than: 0 }

  belongs_to :invoice
  belongs_to :payment_schedule_item
  belongs_to :my_transaction, class_name: 'Transaction', foreign_key: 'transaction_id', optional: true
  belongs_to :order_item

  validates :invoice_id, :name, :description, :amount, presence: true
  validate :amount_with_amount_charged

  def price
    amount / order_item.quantity
  end

  def charge_left
    amount - amount_charged
  end

  def paid?
    amount_charged == amount
  end

  def amount_with_amount_charged
    errors.add(:amount, 'amount charged cannot be greater than total amount') if amount_charged > amount
  end
end
