class ChangeVerifiedToVerifiedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :verified_at, :datetime
    add_column :contacts, :verified_at, :datetime
    remove_column :customers, :verified, :boolean
    remove_column :contacts, :verified, :boolean
  end
end
