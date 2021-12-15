class AddDeletedAtToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :deleted_at, :datetime, default: nil, null: true
  end
end
