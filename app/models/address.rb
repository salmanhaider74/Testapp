# == Schema Information
#
# Table name: addresses
#
#  id            :bigint           not null, primary key
#  resource_type :string           not null
#  resource_id   :bigint           not null
#  street        :string
#  suite         :string
#  city          :string
#  state         :string
#  zip           :string
#  country       :string
#  is_default    :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Address < ApplicationRecord
  ADDRESS_ATTRIBUTES  = %w[street suite city state zip country].freeze
  REQUIRED_ATTRIBUTES = %w[street city state zip country].freeze

  belongs_to :resource, polymorphic: true

  attribute :country, :string, default: 'US'
  attribute :is_default, :boolean, default: true

  validate :validator

  before_save :set_default, if: ->(i) { is_default_changed? && i.is_default? }

  scope :default, -> { where(is_default: true) }

  def complete?
    street? && city? && state? && zip? && country?
  end

  def validator
    false if REQUIRED_ATTRIBUTES.any? { |a| attributes[a].blank? }
    # TODO: Validate address
  end

  private

  def set_default
    addresses = Address.where(resource: resource, is_default: true)
    addresses.update(is_default: false) if addresses.count.positive?
  end
end
