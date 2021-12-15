module Common::Types
  class PaymentMethodType < BaseObject
    field :id, ID, null: false
    field :customer, CustomerType, null: true
    field :vendor, VendorType, null: true
    field :is_default, Boolean, null: true
    field :payment_mode, String, null: true
    field :bank, String, null: true
    field :account_name, String, null: true
    field :account_type, String, null: true
    field :routing_number, String, null: true
    field :account_number, String, null: true
    field :contact_name, String, null: true
    field :phone, String, null: true
    field :email, String, null: true
    field :street, String, null: true
    field :suite, String, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :zip, String, null: true
    field :country, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
