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
require 'rails_helper'

RSpec.describe Session, type: :model do
  context 'validations and callbacks' do
    before do
      @session = build(:session)
      Timecop.freeze
    end

    it 'should set token and expiration date' do
      expect(@session.expires_at).to be_nil
      expect(@session.token).to be_nil

      @session.validate
      expect(@session.expires_at.utc).to eq(1.month.from_now.utc)
      expect(@session.token).to be_truthy
    end
  end

  context 'user and contact methods' do
    before do
      @session1 = create(:user_session)
      @session2 = create(:contact_session)
    end

    it 'should return user and contact for appropriate sessions' do
      expect(@session1.user).to be_kind_of(User)
      expect(@session2.user).to be_nil

      expect(@session1.contact).to be_nil
      expect(@session2.contact).to be_kind_of(Contact)
    end
  end

  context 'autheneticate' do
    before do
      @session = create(:user_session)
      Time.freeze
    end

    it 'should return session if token is valid and not expired' do
      expect(Session.authenticate(@session.token).id).to eq(@session.id)
      expect(Session.authenticate('fake')).to be_nil

      Timecop.travel(2.months.from_now)
      expect(Session.authenticate(@session.token)).to be_nil
    end
  end
end
