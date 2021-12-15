class CreatePlaidTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :plaid_tokens do |t|
      t.string :access_token
      t.string :item_id
      t.string :request_id
      t.string :account_id

      t.references :resource, index: true, null: false, polymorphic: true

      t.timestamps
    end
  end
end
