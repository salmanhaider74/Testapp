class ChangeIsActiveDefaultInProduct < ActiveRecord::Migration[6.0]
  def change
    change_column_default :products, :is_active, false
  end
end
