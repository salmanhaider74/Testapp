module Common::Types
  class PaymentScheduleItemType < BaseObject
    field :id, ID, null: false
    field :due_date, GraphQL::Types::ISO8601Date, null: false
    field :formatted_payment, String, null: false
    field :status, String, null: false
    field :invoice, InvoiceType, null: true
  end
end
