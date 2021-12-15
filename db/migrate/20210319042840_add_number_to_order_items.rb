class AddNumberToOrderItems < ActiveRecord::Migration[6.0]
  def change
    add_column :order_items, :number, :string, index: { unique: true }
  end
end
