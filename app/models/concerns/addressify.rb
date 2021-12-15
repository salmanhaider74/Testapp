module Addressify
  extend ActiveSupport::Concern

  included do
    has_many :addresses, as: :resource
    accepts_nested_attributes_for :addresses, allow_destroy: true
  end

  def default_address
    addresses.default.first
  end

  def default_address_id
    default_address.try(:id)
  end

  def street
    default_address.try(:street)
  end

  def suite
    default_address.try(:suite)
  end

  def city
    default_address.try(:city)
  end

  def state
    default_address.try(:state)
  end

  def zip
    default_address.try(:zip)
  end

  def country
    default_address.try(:country)
  end
end
