class AddApplicationSentToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :application_sent, :boolean, null: false, default: false
  end
end
