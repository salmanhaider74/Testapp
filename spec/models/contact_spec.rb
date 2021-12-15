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
require 'rails_helper'

RSpec.describe Contact, type: :model do
  context 'make_primary!' do
    before do
      @contact1 = create(:contact)
      @contact2 = create(:contact, customer: @contact1.customer)
    end

    it 'should make primary if not already' do
      expect(@contact1.primary).to be true
      expect(@contact2.primary).to be false

      expect(@contact2.make_primary!).to be true
      expect(@contact2.primary).to be true
      expect(@contact1.reload.primary).to be false
    end
  end

  context 'default country' do
    before do
      @contact = create(:contact)
    end

    it 'should set default country to US' do
      expect(@contact.country).to eq('US')
    end
  end

  context 'ownership value' do
    it 'should not be greater than 100' do
      @contact = create(:contact)
      expect(@contact).to be_valid
      @contact.ownership = 101
      expect(@contact).to_not be_valid
    end
  end

  context 'encrypted ssn' do
    it 'should not change if masked ssn is set' do
      @contact = create(:contact)
      expect(@contact).to be_valid
      encrypted_ssn = @contact.encrypted_ssn
      @contact.ssn = '*******1234'
      expect(@contact.encrypted_ssn).to eq(encrypted_ssn)
    end
  end
end
