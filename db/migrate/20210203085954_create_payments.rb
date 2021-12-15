class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.references :resource, null: false, index: true, polymorphic: true
      t.integer :external_id
      t.monetize :amount
      t.string :status

      t.timestamps
    end
  end
end
