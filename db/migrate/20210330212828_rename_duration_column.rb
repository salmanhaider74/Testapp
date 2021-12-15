class RenameDurationColumn < ActiveRecord::Migration[6.0]
  def up
    rename_column :orders, :duration, :term
    rename_column :payment_schedules, :duration, :term
    change_column :orders, :term, :decimal
    change_column :payment_schedules, :term, :decimal
  end

  def down
    rename_column :orders, :term, :duration
    rename_column :payment_schedules, :term, :duration
    change_column :orders, :duration, :integer
    change_column :payment_schedules, :duration, :integer
  end
end
