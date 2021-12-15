class AddProductColumnInOrder < ActiveRecord::Migration[6.0]
  def change
    add_reference :orders, :product, index: true, foreign_key: true
  end
end
