class AddSignatureRequestIdToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :signature_request_id, :string, null: true
  end
end
