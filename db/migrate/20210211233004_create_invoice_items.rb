class CreateInvoiceItems < ActiveRecord::Migration[6.0]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, index: true, null: false, foreign_key: true
      t.references :payment_schedule_item, index: true, null: false, foreign_key: true
      t.references :transaction, index: true, foreign_key: true
      t.references :order_item, index: true, foreign_key: true
      t.string :name
      t.string :description
      t.monetize :amount, null: false

      t.timestamps
    end
  end
end
