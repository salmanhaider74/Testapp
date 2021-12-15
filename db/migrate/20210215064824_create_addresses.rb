class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.references :resource, null: false, index: true, polymorphic: true
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.boolean :is_default, default: false

      t.timestamps
    end

    remove_column :vendors, :street, :string
    remove_column :vendors, :suite, :string
    remove_column :vendors, :city, :string
    remove_column :vendors, :state, :string
    remove_column :vendors, :zip, :string
    remove_column :vendors, :country, :string
    remove_column :customers, :street, :string
    remove_column :customers, :suite, :string
    remove_column :customers, :city, :string
    remove_column :customers, :state, :string
    remove_column :customers, :zip, :string
    remove_column :customers, :country, :string
    remove_column :contacts, :street, :string
    remove_column :contacts, :suite, :string
    remove_column :contacts, :city, :string
    remove_column :contacts, :state, :string
    remove_column :contacts, :zip, :string
    remove_column :contacts, :country, :string
    remove_column :payment_methods, :street, :string
    remove_column :payment_methods, :suite, :string
    remove_column :payment_methods, :city, :string
    remove_column :payment_methods, :state, :string
    remove_column :payment_methods, :zip, :string
    remove_column :payment_methods, :country, :string
  end
end
