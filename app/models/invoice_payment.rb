# == Schema Information
#
# Table name: invoice_payments
#
#  id         :bigint           not null, primary key
#  invoice_id :bigint           not null
#  payment_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class InvoicePayment < ApplicationRecord
  belongs_to :invoice
  belongs_to :payment

  validates :invoice_id, :payment_id, presence: true
end
