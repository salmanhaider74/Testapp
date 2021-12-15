class AddEntityTypeAndDateStartedToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :entity_type, :string
    add_column :customers, :date_started, :date
  end
end
