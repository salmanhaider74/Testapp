# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  customer_id   :bigint
#  first_name    :string
#  last_name     :string
#  phone         :string
#  email         :string
#  role          :string
#  encrypted_ssn :string
#  dob           :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  primary       :boolean          default(FALSE), not null
#  ownership     :decimal(, )
#  deleted_at    :datetime
#  inquiry_id    :string
#  verified_at   :datetime
#
class Contact < ApplicationRecord
  include Phonify
  include Addressify
  include Encryptable
  extend Enumerize

  has_paper_trail

  default_scope { where(deleted_at: nil) }

  belongs_to :customer
  has_many :personal_guarantees

  enumerize :role, in: [:owner, :officer, :owner_officer, :other], predicates: true

  encrypts :ssn, mask: 4

  validates :ownership, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true }
  validates :email, :first_name, :last_name, presence: true
  validates :email, email: true, if: :email_changed?
  validates_uniqueness_of :email, scope: :customer_id

  before_save :default_primary
  before_save :inquiry_status, if: :inquiry_id_changed?

  def full_name
    "#{first_name} #{last_name}"
  end

  def make_primary!
    return false if primary?

    transaction do
      current = customer.primary_contact
      current.update!(primary: false) if current.present?
      update!(primary: true)
      true
    end
  end

  def complete?
    first_name? && last_name? && phone? && role? && reviewed?
  end

  def owner_role?
    role == :owner || role == :officer || role == :owner_officer
  end

  def inquiry_completed?
    verified_at.present?
  end

  private

  def inquiry_status
    return nil unless inquiry_id.present?

    inquiry_response = PersonaService.inquiry inquiry_id
    status = inquiry_response.body.dig('data', 'attributes', 'status')
    self.verified_at = Time.now if status == 'completed'
  end

  def default_primary
    primary = customer.primary_contact
    self.primary = true unless primary.present?
  end
end
