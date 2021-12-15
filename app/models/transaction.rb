# == Schema Information
#
# Table name: transactions
#
#  id                 :bigint           not null, primary key
#  account_id         :bigint
#  order_id           :bigint
#  type               :string
#  status             :string
#  interest_cents     :integer          default(0), not null
#  interest_currency  :string           default("USD"), not null
#  fees_cents         :integer          default(0), not null
#  fees_currency      :string           default("USD"), not null
#  principal_cents    :integer          default(0), not null
#  principal_currency :string           default("USD"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_id         :integer
#  number             :string
#
class Transaction < ApplicationRecord
  self.inheritance_column = :_type_disabled
  include Numerify

  extend Enumerize

  enumerize :type, in: [:debit, :credit], predicates: true
  enumerize :status, in: [:pending, :posted], default: 'posted', predicates: true
  monetize :interest_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :fees_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :principal_cents

  belongs_to :account
  belongs_to :payment, optional: true
  belongs_to :order, optional: true

  validates :account_id, presence: true

  scope :debit, -> { where(type: :debit) }
  scope :credit, -> { where(type: :credit) }
  scope :fees_between, ->(min, max) { where(fees_cents: min..max) }

  def amount
    principal + interest
  end

  def formatted_amount
    amount.format
  end
end
