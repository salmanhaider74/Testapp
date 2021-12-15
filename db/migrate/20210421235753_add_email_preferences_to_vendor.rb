class AddEmailPreferencesToVendor < ActiveRecord::Migration[6.0]
  def change
    add_column    :vendors, :email_preferences, :jsonb, null: false, default: {}
    add_column    :vendors, :contact_email, :string
    add_reference :orders, :user, index: true, foreign_key: true
  end
end
