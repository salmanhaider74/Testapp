class AddPaymentReferenceInTranscation < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :payment_id, :integer, index: true, foreign_key: true
  end
end
