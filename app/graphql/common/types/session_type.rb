module Common::Types
  class SessionType < BaseObject
    field :id, ID, null: false
    field :token, String, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, UserType, null: true
    field :contact, ContactType, null: true
    field :order, OrderType, null: true
  end
end
