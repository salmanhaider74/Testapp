class CreatePaymentScheduleItems < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_schedule_items do |t|
      t.references :payment_schedule, index: true, foreign_key: true
      t.monetize :principal
      t.monetize :interest
      t.datetime :due_date

      t.timestamps
    end
  end
end
