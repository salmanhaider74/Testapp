class CreatePaymentSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_schedules do |t|
      t.references :account
      t.integer :version, default: 1
      t.string :status
      t.integer :duration
      t.datetime :start_date
      t.datetime :end_date
      t.string :billing_frequency
      t.decimal :interest_rate

      t.timestamps
    end
  end
end
