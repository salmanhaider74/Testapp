module Common::Types
  class OrderType < BaseObject
    field :id, ID, null: false
    field :number, String, null: false
    field :status, String, null: false
    field :term, Float, null: false
    field :amount, Float, null: false
    field :formatted_amount, String, null: false
    field :formatted_fee, String, null: false
    field :formatted_fee_percentage, String, null: false
    field :formatted_payment, String, null: false
    field :interest_rate, Float, null: false
    field :interest_rate_subsidy, Float, null: false
    field :advance, Float, null: false
    field :interest, Float, null: false
    field :payment, Float, null: false
    field :discount, Float, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :approved_at, GraphQL::Types::ISO8601DateTime, null: true
    field :financed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :order_items, [OrderItemType], null: true
    field :customer, CustomerType, null: false
    field :workflow_steps, GraphQL::Types::JSON, null: false
    field :personal_guarantee, PersonalGuaranteeType, null: true
    field :signature_url, String, null: true
    field :account, AccountType, null: true
    field :application_sent, Boolean, null: true
    field :loan_decision, String, null: false
    field :fullcheck_consent, Boolean, null: true
    field :formatted_credit_limit, String, null: true
    field :user_documents, [UserDocumentType], null: false
  end
end
