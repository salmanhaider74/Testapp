# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  first_name             :string
#  last_name              :string
#  phone                  :string
#  vendor_id              :bigint
#  email                  :string           not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#
class User < ApplicationRecord
  include Phonify

  devise :database_authenticatable, :registerable, :recoverable, :validatable

  has_many :sessions, as: :resource
  belongs_to :vendor

  validates :email, :encrypted_password, :first_name, :last_name, presence: true
  validates :email, email: true, if: :email_changed?

  def track_login!(remote_ip)
    self.sign_in_count      = sign_in_count + 1
    self.last_sign_in_at    = current_sign_in_at
    self.last_sign_in_ip    = current_sign_in_ip
    self.current_sign_in_at = Time.now
    self.current_sign_in_ip = remote_ip

    save
  end
end
