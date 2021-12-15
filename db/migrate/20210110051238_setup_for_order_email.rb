class SetupForOrderEmail < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :number, :string, index: { unique: true }
    add_column :contacts, :primary, :boolean, null: false, default: false
    add_index :vendors, :domain, unique: true
    add_index :contacts, [:customer_id, :primary], unique: true, where: 'contacts.primary is true'
    add_index :contacts, [:customer_id, :email], unique: true
    add_reference :sessions, :order, index: true
  end
end
