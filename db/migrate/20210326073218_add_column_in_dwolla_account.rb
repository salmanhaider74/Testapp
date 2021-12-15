class AddColumnInDwollaAccount < ActiveRecord::Migration[6.0]
  def change
    rename_column :dwolla_accounts, :type, :is_master
  end
end
