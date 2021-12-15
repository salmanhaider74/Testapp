class AddFinancialDetailsToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :financial_details, :jsonb, default: {}, null: false
  end
end
