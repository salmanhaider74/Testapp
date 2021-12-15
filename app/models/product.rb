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
class Product < ApplicationRecord
  include Numerify

  BORROWER_TYPES = %w[prime near_prime sub_prime].freeze
  MAX_TERM = 60

  monetize :min_initial_loan_amount_cents, { greater_than: 0 }
  monetize :min_subsequent_loan_amount_cents, { greater_than: 0 }
  monetize :max_loan_amount_cents, { greater_than: 0 }

  belongs_to :vendor
  has_many :orders

  attr_accessor :min_interest_rate_subsidy_percentage, :max_interest_rate_subsidy_percentage

  before_save :set_active, if: ->(i) { is_active_changed? && i.is_active? }

  validates :vendor_id, presence: true
  validates :min_interest_rate_subsidy, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :max_interest_rate_subsidy, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :min_initial_loan_amount, presence: true
  validates :min_subsequent_loan_amount, presence: true
  validates :max_loan_amount, presence: true
  validates :pricing_schema, presence: true
  validate :interest_rate_subsidy
  validates :name, :vendor_id, :min_interest_rate_subsidy, :max_interest_rate_subsidy,
            :min_subsequent_loan_amount, :min_subsequent_loan_amount, :max_loan_amount,
            :pricing_schema, frozen: true, if: :frozen?
  validate :validate_pricing_schema

  before_validation :set_interest_rate_subsidy

  def interest_rate(borrower_type, duration)
    return unless BORROWER_TYPES.include?(borrower_type)

    duration = get_closest_term(borrower_type, duration.to_i)
    return unless duration.present?

    if pricing_schema.key?('concentration_level')
      rate = BORROWER_TYPES.inject(0) do |r, b|
        r + pricing_schema['concentration_level'][b] * pricing_schema['interest_rates'][b][duration]
      end
      BigDecimal(rate, 4)
    else
      pricing_schema['interest_rates'][borrower_type][duration]
    end
  end

  def blended_rate
    return nil unless pricing_schema.key?('concentration_level')

    blended_rate = {}
    pricing_schema['interest_rates'].each do |borrower, durations|
      blended_rate[borrower] = {}
      durations.each do |duration, _v|
        rate = BORROWER_TYPES.inject(0) do |r, b|
          r + pricing_schema['concentration_level'][b] * pricing_schema['interest_rates'][b][duration]
        end
        blended_rate[borrower][duration] = BigDecimal(rate, 4)
      end
    end
    blended_rate
  end

  def frozen?
    orders.count.positive?
  end

  def max_duration_allowed
    pricing_schema.dig('interest_rates', 'prime').keys.map(&:to_i).max
  end

  def min_duration_allowed
    pricing_schema.dig('interest_rates', 'prime').keys.map(&:to_i).min
  end

  def set_active
    products = vendor.products.where(is_active: true)
    products.update(is_active: false) if products.count.positive?
  end

  private

  def set_interest_rate_subsidy
    self.min_interest_rate_subsidy = min_interest_rate_subsidy_percentage.to_f / 100 if min_interest_rate_subsidy_percentage.present?
    self.max_interest_rate_subsidy = max_interest_rate_subsidy_percentage.to_f / 100 if max_interest_rate_subsidy_percentage.present?
  end

  def interest_rate_subsidy
    errors.add(:min_interest_rate_subsidy_percentage, 'Minimum interest rate subsidy should be less than Maximum interest rate subsidy') if min_interest_rate_subsidy > max_interest_rate_subsidy
    errors.add(:min_interest_rate_subsidy_percentage, 'Maximum interest rate subsidy should be greater than Minimum interest rate subsidy') if max_interest_rate_subsidy < min_interest_rate_subsidy
  end

  def get_closest_term(borrower_type, duration)
    pricing_schema.dig('interest_rates', borrower_type).keys.sort
                  .find { |n| n.to_i == duration || n.to_i > duration }
  end

  def validate_pricing_schema
    self.pricing_schema = JSON.parse(pricing_schema) if pricing_schema.instance_of?(String)

    errors.add(:pricing_schema, 'interest rate are invalid') if BORROWER_TYPES.any? { |b| pricing_schema.dig('interest_rates', b).nil? || pricing_schema.dig('interest_rates', b).values.any? { |v| v <= 0 || v > 1 } }
    errors.add(:pricing_schema, 'interest rate are invalid') if BORROWER_TYPES.any? { |b| pricing_schema.dig('interest_rates', b).nil? || pricing_schema.dig('interest_rates', b).values.any? { |v| v <= 0 || v > 1 } }
    if pricing_schema['concentration_level'].present?
      errors.add(:pricing_schema, 'concentrations should have all borrower types') if BORROWER_TYPES.any? { |b| pricing_schema.dig('concentration_level', b).nil? || pricing_schema.dig('concentration_level', b).negative? }
      errors.add(:pricing_schema, 'concentrations should add upto 0') if BORROWER_TYPES.inject(0) { |s, b| s + (pricing_schema.dig('concentration_level', b) || 0) } != 1
    end

    errors.add(:pricing_schema, 'terms of prime, near_prime and sub_prime are not identical') if Set.new(BORROWER_TYPES.map { |b| (pricing_schema.dig('interest_rates', b) || {}).keys }).size > 1
    errors.add(:pricing_schema, 'term is greater than allowed term') if BORROWER_TYPES.any? { |b| (pricing_schema.dig('interest_rates', b) || {}).keys.map(&:to_i).max.to_i > MAX_TERM }
  rescue JSON::ParserError
    errors.add(:pricing_schema, 'should be a valid json')
  end
end
