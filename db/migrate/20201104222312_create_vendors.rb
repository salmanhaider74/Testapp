class CreateVendors < ActiveRecord::Migration[6.0]
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :duns_number
      t.string :ein
      t.string :domain

      t.timestamps
    end
  end
end
