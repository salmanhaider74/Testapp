class AddOwnershipToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :ownership, :decimal
  end
end
