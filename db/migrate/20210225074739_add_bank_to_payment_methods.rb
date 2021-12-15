class AddBankToPaymentMethods < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_methods, :bank, :string
  end
end
