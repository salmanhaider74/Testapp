class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.references :resource, null: false, index: true, polymorphic: true
      t.references :order, index: true, foreign_key: true
      t.monetize :balance

      t.timestamps
    end
  end
end
