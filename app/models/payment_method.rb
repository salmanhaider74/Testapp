# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  resource_type            :string           not null
#  resource_id              :bigint           not null
#  is_default               :boolean          default(TRUE)
#  payment_mode             :string
#  account_name             :string
#  account_type             :string
#  routing_number           :string
#  encrypted_account_number :string
#  contact_name             :string
#  phone                    :string
#  email                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank                     :string
#  funding_source           :string
#  verified                 :boolean          default(FALSE), not null
#
class PaymentMethod < ApplicationRecord
  include Addressify
  include Encryptable
  extend Enumerize

  default_scope { where(verified: true) }

  belongs_to :resource, polymorphic: true
  has_many :payments
  has_one :plaid_token, as: :resource

  before_save :set_default, if: ->(i) { is_default_changed? && i.is_default? }
  after_save :create_funding_source, if: ->(_i) { ach? || plaid? }

  enumerize :payment_mode, in: [:ach, :invoice, :plaid], predicates: true
  # enumerize :account_type, in: [:checking, :savings], predicates: true

  encrypts :account_number, mask: 4

  # validates :payment_mode, presence: true
  validates :bank, :account_name, :account_type, :routing_number, :encrypted_account_number, presence: true, if: :ach?
  validates :contact_name, :phone, :email, presence: true, if: :invoice?

  validate :default_address_present, if: :invoice?

  attribute :is_default, :boolean, default: true

  def test_mode_enabled?
    mode = false
    case resource
    when Customer
      mode = resource.vendor.test_mode
    when Vendor
      mode = resource.test_mode
    end

    mode
  end

  private

  def default_address_present
    default_address.present?
  end

  def set_default
    payment_methods = PaymentMethod.where(resource: resource, is_default: true)
    payment_methods.update(is_default: false) if payment_methods.count.positive?
  end

  def create_funding_source
    return unless funding_source.nil?

    payment_service = PaymentService::Service.new
    if resource.dwolla_account.present?
      payment_service.create_funding_source(resource.dwolla_account, self)
    else
      DwollaAccount.create_account(resource, resource.is_a?(Vendor))
      payment_service.create_funding_source(resource.reload.dwolla_account, self)
    end
  end
end
