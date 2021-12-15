module Common::Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :phone, String, null: true
    field :vendor_id, Integer, null: true
    field :email, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :vendor, VendorType, null: true
  end
end
