class AddColumnInvoiceDateInInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :invoice_date, :date
  end
end
