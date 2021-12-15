class AddAmountPaidToInvoiceItems < ActiveRecord::Migration[6.0]
  def change
    add_monetize :invoice_items, :amount_charged, null: false
  end
end
