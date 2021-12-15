class ChangePrecisionOfInterestColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :orders, :interest_rate, :decimal, precision: 5, scale: 4
    change_column :products, :min_interest_rate_subsidy, :decimal, precision: 5, scale: 4
    change_column :products, :max_interest_rate_subsidy, :decimal, precision: 5, scale: 4
  end

  def down
    change_column :orders, :interest_rate, :decimal, precision: 4, scale: 4
    change_column :products, :min_interest_rate_subsidy, :decimal, precision: 4, scale: 4
    change_column :products, :max_interest_rate_subsidy, :decimal, precision: 4, scale: 4
  end
end
