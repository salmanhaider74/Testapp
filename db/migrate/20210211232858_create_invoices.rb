class CreateInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :invoices do |t|
      t.references :customer, index: true, foreign_key: true
      t.monetize :amount, null: false
      t.string :status
      t.date :posted_date
      t.date :due_date

      t.timestamps
    end
  end
end
