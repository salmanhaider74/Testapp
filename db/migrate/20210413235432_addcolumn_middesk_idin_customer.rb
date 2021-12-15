class AddcolumnMiddeskIdinCustomer < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :middesk_id, :string
  end
end
