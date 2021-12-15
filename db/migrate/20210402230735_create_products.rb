class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.references :vendor, index: true, null: false, foreign_key: true
      t.string :name
      t.boolean :is_active, default: true
      t.string :number, index: { unique: true }
      t.decimal :min_interest_rate_subsidy, precision: 4, scale: 4
      t.decimal :max_interest_rate_subsidy, precision: 4, scale: 4
      t.monetize :min_initial_loan_amount
      t.monetize :min_subsequent_loan_amount
      t.monetize :max_loan_amount
      t.jsonb :pricing_schema, default: {}, null: false

      t.timestamps
    end
  end
end
