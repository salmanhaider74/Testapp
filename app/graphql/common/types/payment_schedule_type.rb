module Common::Types
  class PaymentScheduleType < BaseObject
    field :id, ID, null: false
    field :payment_schedule_items, [PaymentScheduleItemType], null: false
  end
end
