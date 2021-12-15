class CreateInvoicePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :invoice_payments do |t|
      t.references :invoice, index: true, null: false, foreign_key: true
      t.references :payment, index: true, null: false, foreign_key: true

      t.timestamps
    end

    add_column :payments, :error_message, :string, null: true
    add_reference :payments, :payment_method, index: true, null: false, foreign_key: true
  end
end
