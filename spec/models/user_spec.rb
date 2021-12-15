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
require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    before do
      @user = build(:user)
    end

    it 'should validate email' do
      expect(@user.valid?).to be true

      @user.email = 'asd@??.com'
      expect(@user.valid?).to be false

      @user.email = 'abc@@google.com'
      expect(@user.valid?).to be false
    end

    it 'should validate phone' do
      expect(@user.valid?).to be true

      @user.phone = '3143112123'
      expect(@user.valid?).to be false

      @user.phone = '12312312'
      expect(@user.valid?).to be false

      @user.phone = '+13177587403'
      expect(@user.valid?).to be true
    end
  end
end
