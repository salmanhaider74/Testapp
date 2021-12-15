class AddColumnsInDwollaAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :dwolla_accounts, :verified, :boolean, null: false, default: false
    add_column :dwolla_accounts, :funding_source, :string
  end
end
