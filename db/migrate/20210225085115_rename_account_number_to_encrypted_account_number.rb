class RenameAccountNumberToEncryptedAccountNumber < ActiveRecord::Migration[6.0]
  def change
    rename_column :payment_methods, :account_number, :encrypted_account_number
  end
end
