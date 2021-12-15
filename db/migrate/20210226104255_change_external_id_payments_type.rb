class ChangeExternalIdPaymentsType < ActiveRecord::Migration[6.0]
  def change
    change_column :payments, :external_id, :string
  end
end
