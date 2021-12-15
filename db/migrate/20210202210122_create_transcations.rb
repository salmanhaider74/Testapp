class CreateTranscations < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.references :account, index: true, foreign_key: true
      t.references :order, index: true, foreign_key: true
      t.string :type
      t.string :status
      t.monetize :interest
      t.monetize :fees
      t.monetize :principal

      t.timestamps
    end
  end
end
