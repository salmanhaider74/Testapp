class AddColumnInPaymentMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_methods, :verified, :boolean, null: false, default: false
  end
end
