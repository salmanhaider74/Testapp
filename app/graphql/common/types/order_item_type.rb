module Common::Types
  class OrderItemType < BaseObject
    field :id, ID, null: false
    field :number, String, null: false
    field :order, OrderType, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :quantity, Integer, null: false
    field :unit_price, Float, null: false
    field :amount, Float, null: false
    field :formatted_amount, String, null: false
    field :formatted_unit_price, String, null: false
  end
end
