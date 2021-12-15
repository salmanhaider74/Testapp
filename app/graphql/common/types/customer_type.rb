module Common::Types
  class CustomerType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :number, String, null: false
    field :status, String, null: false
    field :street, String, null: true
    field :suite, String, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :zip, String, null: true
    field :country, String, null: true
    field :duns_number, String, null: true
    field :ein, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :contacts, [ContactType], null: false
    field :entity_type, String, null: true
    field :date_started, GraphQL::Types::ISO8601Date, null: true
    field :default_payment_method, PaymentMethodType, null: true
    field :bill_cycle_day, Integer, null: true
    field :amount, Float, null: false
    field :discount, Float, null: false
    field :formatted_amount, String, null: false
    field :formatted_fee, String, null: false
    field :formatted_fee_percentage, String, null: false
    field :complete_order_end_date, GraphQL::Types::ISO8601Date, null: true
    field :vendor, VendorType, null: true
    field :orders, [OrderType], null: true
    field :invoices, [InvoiceType], null: true
    field :payment_schedule_items, [PaymentScheduleItemType], null: true
    field :primary_contact, ContactType, null: true
  end
end
