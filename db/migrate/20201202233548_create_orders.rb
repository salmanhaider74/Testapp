class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :status
      t.decimal :amount
      t.decimal :interest_rate
      t.integer :num_years
      t.string :billing_frequency
      t.string :interest_method
      t.date :start_date
      t.date :end_date
      t.datetime :approved_at
      t.datetime :declined_at
      t.references :customer, index: true

      t.timestamps
    end
  end
end
