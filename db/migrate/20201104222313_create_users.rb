class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.references :vendor, index: true

      ## Database authenticatable
      t.string :email,              null: false, index: { unique: true }
      t.string :encrypted_password, null: false

      ## Recoverable
      t.string   :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at

      ## Confirmable
      # t.string   :confirmation_token, index: true
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      t.timestamps null: false
    end
  end
end
