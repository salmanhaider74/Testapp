# == Schema Information
#
# Table name: products
#
#  id                                  :bigint           not null, primary key
#  vendor_id                           :bigint           not null
#  name                                :string
#  is_active                           :boolean          default(TRUE)
#  number                              :string
#  min_interest_rate_subsidy           :decimal(5, 4)
#  max_interest_rate_subsidy           :decimal(5, 4)
#  min_initial_loan_amount_cents       :integer          default(0), not null
#  min_initial_loan_amount_currency    :string           default("USD"), not null
#  min_subsequent_loan_amount_cents    :integer          default(0), not null
#  min_subsequent_loan_amount_currency :string           default("USD"), not null
#  max_loan_amount_cents               :integer          default(0), not null
#  max_loan_amount_currency            :string           default("USD"), not null
#  pricing_schema                      :jsonb            not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'Validations and Methods ' do
    before do
      @vendor = create(:vendor)
      @product = build(:product, vendor: @vendor)
    end

    it 'should validate the interest rate subsidies' do
      expect(@product.valid?).to be true

      @product.min_interest_rate_subsidy = 2.3
      expect(@product.valid?).to be false

      @product.min_interest_rate_subsidy = 0.5
      @product.max_interest_rate_subsidy = 0.3
      expect(@product.valid?).to be false

      @product.min_interest_rate_subsidy = 0.3
      @product.max_interest_rate_subsidy = 0.5
      @product.pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json'))).to_json

      expect(@product.valid?).to be true
    end

    it 'should validate pricing_schema' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      @product.pricing_schema = { "interest_rate": pricing_schema['interest_rates'] }
      expect(@product.valid?).to be false

      @product.pricing_schema = { "interest_rates": pricing_schema['interest_rates']
                                .except('prime') }
      expect(@product.valid?).to be false

      @product.pricing_schema = { "interest_rates": pricing_schema['interest_rates']
                                .except('sub_prime') }
      expect(@product.valid?).to be false

      @product.pricing_schema = { "interest_rates": pricing_schema['interest_rates']
                                .except('near_prime') }
      expect(@product.valid?).to be false

      @product.pricing_schema = { "interest_rates": pricing_schema['interest_rates'] }
      expect(@product.valid?).to be true

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates'] = pricing_schema['interest_rates'].except('prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates'] = pricing_schema['interest_rates'].except('near_prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates'] = pricing_schema['interest_rates'].except('sub_prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false
    end

    it 'should validate concentration_level has prime, near_prime and sub_prime' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level'] = pricing_schema['concentration_level'].except('prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level'] = pricing_schema['concentration_level'].except('near_prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level'] = pricing_schema['concentration_level'].except('sub_prime')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false
    end

    it 'should validate concentration_level sum equal to 100%' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level']['prime'] = 0.30
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level']['near_prime'] = 0.33
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['concentration_level']['sub_prime'] = 0.33
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false
    end

    it 'should validate prime, near_prime and sub_prime has same terms' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['prime'] = pricing_schema['interest_rates']['prime'].except('60')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['near_prime'] = pricing_schema['interest_rates']['near_prime'].except('12')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['sub_prime'] = pricing_schema['interest_rates']['sub_prime'].except('36')
      @product.pricing_schema = pricing_schema
      expect(@product.valid?).to be false
    end
  end

  context 'minumum and maximum duration allowed' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor, is_active: false)
    end

    it 'should validate minumim and maximum duration allowed' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      @product.pricing_schema = pricing_schema
      expect(@product.max_duration_allowed).to eq(60)
      expect(@product.min_duration_allowed).to eq(12)

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['prime'] = pricing_schema['interest_rates']['prime'].except('60')
      pricing_schema['interest_rates']['near_prime'] = pricing_schema['interest_rates']['near_prime'].except('60')
      pricing_schema['interest_rates']['sub_prime'] = pricing_schema['interest_rates']['sub_prime'].except('60')
      @product.pricing_schema = pricing_schema
      expect(@product.max_duration_allowed).to eq(48)
      expect(@product.min_duration_allowed).to eq(12)

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['prime'] = pricing_schema['interest_rates']['prime'].slice('60')
      pricing_schema['interest_rates']['near_prime'] = pricing_schema['interest_rates']['near_prime'].slice('60')
      pricing_schema['interest_rates']['sub_prime'] = pricing_schema['interest_rates']['sub_prime'].slice('60')
      @product.update!(pricing_schema: pricing_schema)

      expect(@product.max_duration_allowed).to eq(60)

      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      pricing_schema['interest_rates']['prime'] = pricing_schema['interest_rates']['prime'].except('48')
      pricing_schema['interest_rates']['near_prime'] = pricing_schema['interest_rates']['near_prime'].except('48')
      pricing_schema['interest_rates']['sub_prime'] = pricing_schema['interest_rates']['sub_prime'].except('48')
      @product.pricing_schema = pricing_schema
      expect(@product.max_duration_allowed).to eq(60)
      expect(@product.min_duration_allowed).to eq(12)
    end
  end

  context 'one Active Product At a Time' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @second_product = create(:product, vendor: @vendor.reload)
    end

    it 'should validate only one active product' do
      @product.is_active = true
      @product.save
      expect(@product.is_active).to be true
      @second_product.is_active = true
      @second_product.save
      expect(@product.reload.is_active).to be false
    end
  end

  context 'Freeze Product if it has a order' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should validate only one active product' do
      expect(@product.update(min_interest_rate_subsidy: 0.01)).to be false
      expect(@product.update(max_loan_amount: 100_000)).to be false
      expect(@product.update(min_initial_loan_amount: 100_000)).to be false
    end
  end

  context 'interest Rate' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
    end

    it 'Get belended Interest Rate for prime customer' do
      expect(@product.interest_rate('prime', '12')).to eq(0.097)
      expect(@product.interest_rate('prime', '24')).to eq(0.107)
      expect(@product.interest_rate('prime', '36')).to eq(0.117)
      expect(@product.interest_rate('prime', '80')).to eq(nil)
    end

    it 'Get belended Interest Rate for new prime customer' do
      expect(@product.interest_rate('near_prime', '12')).to eq(0.097)
      expect(@product.interest_rate('near_prime', '24')).to eq(0.107)
      expect(@product.interest_rate('near_prime', '36')).to eq(0.117)
      expect(@product.interest_rate('near_prime', '80')).to eq(nil)
    end

    it 'Get belended Interest Rate for new prime customer' do
      expect(@product.interest_rate('sub_prime', '12')).to eq(0.097)
      expect(@product.interest_rate('sub_prime', '24')).to eq(0.107)
      expect(@product.interest_rate('sub_prime', '36')).to eq(0.117)
      expect(@product.interest_rate('sub_prime', '80')).to eq(nil)
    end

    it 'Non blended interest rate' do
      pricing_schema = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      @product.update(pricing_schema: { "interest_rates": pricing_schema['interest_rates'] })
      expect(@product.interest_rate('prime', '12')).to eq(0.08)
      expect(@product.interest_rate('near_prime', '24')).to eq(0.11)
      expect(@product.interest_rate('sub_prime', '36')).to eq(0.14)
      expect(@product.interest_rate('sub_prime', '100')).to eq(nil)
    end

    it 'interest rate closest term or duration' do
      pricing_schema  = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json')))
      @product.update(pricing_schema: { "interest_rates": pricing_schema['interest_rates'] })
      expect(@product.interest_rate('prime', '6.5')).to eq(0.08)
      expect(@product.interest_rate('near_prime', '15')).to eq(0.11)
      expect(@product.interest_rate('sub_prime', '18')).to eq(0.13)
      expect(@product.interest_rate('sub_prime', '25')).to eq(0.14)
      expect(@product.interest_rate('sub_prime', '100')).to eq(nil)
    end
  end
end
