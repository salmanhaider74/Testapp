class AddColumnsInContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :inquiry_id, :string, null: true
    add_column :contacts, :verified, :boolean, null: false, default: false
  end
end
