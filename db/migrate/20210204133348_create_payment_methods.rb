class CreatePaymentMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_methods do |t|
      t.references :resource, index: true, null: false, polymorphic: true
      t.boolean :is_default, default: false
      t.string :payment_mode
      t.string :account_name
      t.string :account_type
      t.string :routing_number
      t.string :account_number
      t.string :contact_name
      t.string :phone
      t.string :email
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
