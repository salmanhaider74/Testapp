# == Schema Information
#
# Table name: sessions
#
#  id             :bigint           not null, primary key
#  resource_type  :string           not null
#  resource_id    :bigint           not null
#  token          :string           not null
#  expires_at     :datetime         not null
#  last_active_at :datetime
#  sign_in_ip     :inet
#  current_ip     :inet
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  order_id       :bigint
#
class Session < ApplicationRecord
  DEFAULT_EXPIRATION_TIME = 1.month.freeze

  belongs_to :resource, polymorphic: true
  belongs_to :order, optional: true

  before_validation :set_token_and_expiration, on: :create

  scope :active, -> { where('expires_at > ?', Time.now.utc) }

  def self.authenticate(token)
    Session.where(token: token).where('expires_at > ?', Time.now.utc).first
  end

  def user
    resource if resource.is_a?(User)
  end

  def contact
    resource if resource.is_a?(Contact)
  end

  private

  def set_token_and_expiration
    self.expires_at ||= DEFAULT_EXPIRATION_TIME.from_now
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Session.exists?(token: random_token)
    end
  end
end
