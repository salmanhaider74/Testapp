module Common::Types
  class InvoiceType < BaseObject
    field :id, ID, null: false
    field :number, String, null: false
    field :status, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :due_date, GraphQL::Types::ISO8601DateTime, null: false
    field :amount, Float, null: false
    field :url, String, null: true
    field :formatted_amount, String, null: false
    field :invoice_payments, [InvoicePaymentType], null: false
  end
end
