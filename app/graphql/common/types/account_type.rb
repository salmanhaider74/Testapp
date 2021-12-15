module Common::Types
  class AccountType < BaseObject
    field :id, ID, null: false
    field :customer, CustomerType, null: true
    field :vendor, VendorType, null: true
    field :order, OrderType, null: true
    field :transactions, [TransactionType], null: false
    field :balance, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :payment_schedule, PaymentScheduleType, null: false
  end
end
