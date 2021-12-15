class AddColumnsInPaymentScheduleItem < ActiveRecord::Migration[6.0]
  def change
    add_monetize :payment_schedule_items, :fees, null: false
    add_monetize :payment_schedule_items, :start_balance, null: false
  end
end
