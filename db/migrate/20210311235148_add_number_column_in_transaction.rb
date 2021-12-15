class AddNumberColumnInTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :number, :string, index: { unique: true }
  end
end
