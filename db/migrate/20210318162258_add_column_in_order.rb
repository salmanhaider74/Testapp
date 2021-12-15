class AddColumnInOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :has_form, :boolean, null: false, default: false
  end
end
