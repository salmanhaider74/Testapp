class AddReviewedColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :reviewed, :boolean, default: false, null: false
    add_column :contacts, :reviewed, :boolean, default: false, null: false
  end
end
