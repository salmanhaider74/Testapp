class ChangePrecisionOfInterestRateSubsidy < ActiveRecord::Migration[6.0]
  def up
    change_column :orders, :interest_rate_subsidy, :decimal, precision: 5, scale: 4
  end

  def down
    change_column :orders, :interest_rate_subsidy, :decimal, precision: 4, scale: 4
  end
end
