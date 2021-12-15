class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.references :order, index: true, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description, null: false
      t.integer :quantity, null: false
      t.monetize :unit_price, null: false

      t.timestamps
    end
  end
end
