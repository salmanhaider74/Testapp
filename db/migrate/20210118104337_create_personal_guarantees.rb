class CreatePersonalGuarantees < ActiveRecord::Migration[6.0]
  def change
    create_table :personal_guarantees do |t|
      t.references :order, index: true, null: false, foreign_key: true
      t.references :contact, index: true, null: false, foreign_key: true
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :personal_guarantees, [:order_id, :contact_id], unique: true
  end
end
