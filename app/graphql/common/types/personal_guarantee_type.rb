module Common::Types
  class PersonalGuaranteeType < BaseObject
    field :id, ID, null: false
    field :accepted_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :contact, ContactType, null: false
    field :order, OrderType, null: false
  end
end
