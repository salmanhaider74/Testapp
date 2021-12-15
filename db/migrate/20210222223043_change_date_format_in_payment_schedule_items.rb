class ChangeDateFormatInPaymentScheduleItems < ActiveRecord::Migration[6.0]
  def change
    change_column :payment_schedule_items, :due_date, :date
  end
end
