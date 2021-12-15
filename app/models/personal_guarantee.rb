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
class PersonalGuarantee < ApplicationRecord
  belongs_to :order
  belongs_to :contact
  has_many :documents

  validates :order_id, :contact_id, presence: true
  validates :order_id, :contact_id, :accepted_at, frozen: true, if: :frozen?

  scope :accepted, -> { where.not(accepted_at: nil) }

  def frozen?
    accepted_at_was.present?
  end
end
