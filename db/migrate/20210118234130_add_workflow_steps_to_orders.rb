class AddWorkflowStepsToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :workflow_steps, :jsonb, default: {}
    add_column :orders, :undewriting_engine_version, :string, default: 'V1'
  end
end
