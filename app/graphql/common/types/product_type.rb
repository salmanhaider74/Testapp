module Common::Types
  class ProductType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :number, String, null: false
    field :min_interest_rate_subsidy, Float, null: false
    field :max_interest_rate_subsidy, Float, null: false
    field :min_initial_loan_amount, Float, null: false
    field :min_subsequent_loan_amount, Float, null: false
    field :max_loan_amount, Float, null: false
    field :max_duration_allowed, Float, null: false
  end
end
