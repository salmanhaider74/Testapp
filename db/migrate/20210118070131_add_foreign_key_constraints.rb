class AddForeignKeyConstraints < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :users, :vendors, validate: true
    add_foreign_key :customers, :vendors, validate: true
    add_foreign_key :contacts, :customers, validate: true
    add_foreign_key :orders, :customers, validate: true
    add_foreign_key :sessions, :orders
  end
end
