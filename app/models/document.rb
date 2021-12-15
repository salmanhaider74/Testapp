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
class Document < ApplicationRecord
  self.inheritance_column = nil
  extend Enumerize

  belongs_to :order
  belongs_to :customer
  belongs_to :personal_guarantee, optional: true
  has_one_attached :document

  enumerize :type, in: [:fico, :duns, :experian, :middesk, :financial, :order_form, :tax_return, :bank_statement, :funding_invoice], predicates: true

  validates :customer_id, :type, presence: true

  def pdf?
    document.content_type =~ /pdf/
  end
end
