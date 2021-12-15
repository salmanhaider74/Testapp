class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.references :vendor, index: true
      t.string :name
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :duns_number
      t.string :ein

      t.timestamps
    end
  end
end
