module Common::Types
  class PaymentType < BaseObject
    field :id, ID, null: false
    field :number, String, null: false
    field :external_id, String, null: false
    field :formatted_amount, String, null: false
    field :status, String, null: false
    field :error_message, String, null: false
    field :payment_method, PaymentMethodType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
