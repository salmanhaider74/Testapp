class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts do |t|
      t.references :customer, index: true
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :role
      t.string :ssn
      t.date :dob
      t.string :street
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end
  end
end
