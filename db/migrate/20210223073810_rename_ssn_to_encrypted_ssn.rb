class RenameSsnToEncryptedSsn < ActiveRecord::Migration[6.0]
  def change
    rename_column :contacts, :ssn, :encrypted_ssn
  end
end
