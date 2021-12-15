class AddTestModeToVendors < ActiveRecord::Migration[6.0]
  def change
    add_column :vendors, :test_mode, :boolean, null: false, default: false
  end
end
