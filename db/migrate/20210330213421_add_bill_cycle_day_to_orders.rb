class AddBillCycleDayToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :bill_cycle_day, :integer
  end
end
