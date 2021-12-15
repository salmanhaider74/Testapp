class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.references :customer, index: true, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.references :personal_guarantee, null: true, foreign_key: true
      t.string :type
      t.jsonb :json_data, null: false, default: {}
    end
  end
end
