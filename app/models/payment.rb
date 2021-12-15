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
class Payment < ApplicationRecord
  include Numerify
  extend Enumerize

  belongs_to :resource, polymorphic: true
  belongs_to :payment_method
  has_many :invoice_payments
  has_many :transactions

  enumerize :status, in: [:pending, :processed, :error], default: 'pending', predicates: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method_id, presence: true

  monetize :amount_cents, { greater_than: 0 }

  def formatted_amount
    amount.format
  end
end
