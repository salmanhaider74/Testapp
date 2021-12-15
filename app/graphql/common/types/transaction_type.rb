module Common::Types
  class TransactionType < BaseObject
    field :id, ID, null: false
    field :number, String, null: false
    field :type, String, null: false
    field :status, String, null: false
    field :principal, Float, null: false
    field :fees, Float, null: false
    field :interest, Float, null: false
    field :amount, Float, null: false
    field :formatted_amount, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :order, OrderType, null: true
    field :account, AccountType, null: false
    field :payment, PaymentType, null: false
  end
end
