class RefactorOrders < ActiveRecord::Migration[6.0]
  def change
    remove_column :orders, :num_years, :integer
    remove_column :orders, :interest_method, :string
    remove_column :orders, :amount, :decimal
    remove_column :orders, :interest_rate
    add_monetize :orders, :amount
    add_column :orders, :duration, :integer
    add_column :orders, :interest_rate, :decimal, precision: 4, scale: 4
    add_column :orders, :interest_rate_subsidy, :decimal, precision: 4, scale: 4
  end
end
