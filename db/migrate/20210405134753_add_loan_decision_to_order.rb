class AddLoanDecisionToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :loan_decision, :string
    add_column :orders, :vartana_rating, :string
    add_column :orders, :vartana_score, :decimal, precision: 4, scale: 2
    add_column :orders, :manual_review, :boolean, null: false, default: false
    add_column :orders, :fullcheck_consent, :boolean, null: false, default: false
  end
end
