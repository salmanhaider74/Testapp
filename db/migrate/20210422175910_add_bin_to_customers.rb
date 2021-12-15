class AddBinToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :bin, :string
  end
end
