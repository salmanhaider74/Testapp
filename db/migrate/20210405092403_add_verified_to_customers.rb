class AddVerifiedToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :verified, :boolean, null: false, default: false
  end
end
