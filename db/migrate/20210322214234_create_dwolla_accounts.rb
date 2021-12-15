class CreateDwollaAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :dwolla_accounts do |t|
      t.references :resource, null: false, index: true, polymorphic: true
      t.string :type
      t.string :url

      t.timestamps
    end
  end
end
