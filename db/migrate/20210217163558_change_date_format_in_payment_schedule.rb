class ChangeDateFormatInPaymentSchedule < ActiveRecord::Migration[6.0]
  def change
    change_column :payment_schedules, :start_date, :date
    change_column :payment_schedules, :end_date, :date
  end
end
