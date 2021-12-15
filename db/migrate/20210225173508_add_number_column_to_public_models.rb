class AddNumberColumnToPublicModels < ActiveRecord::Migration[6.0]
  def change
    add_column :vendors, :number, :string, index: { unique: true }
    add_column :customers, :number, :string, index: { unique: true }
    add_column :payments, :number, :string, index: { unique: true }
    add_column :invoices, :number, :string, index: { unique: true }
    add_column :invoice_items, :number, :string, index: { unique: true }
  end
end
