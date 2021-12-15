class AddColumnFundingSourceinPaymentMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_methods, :funding_source, :string, default: nil
  end
end
