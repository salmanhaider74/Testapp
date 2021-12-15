class RenameEinToEncryptedEin < ActiveRecord::Migration[6.0]
  def change
    rename_column :customers, :ein, :encrypted_ein
  end
end
