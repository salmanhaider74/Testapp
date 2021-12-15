ActiveAdmin.register Account do
  belongs_to :resource, polymorphic: true
  belongs_to :order, optional: true
  actions :all, except: [:index, :destroy, :create, :edit]

  member_action :payout_balance, method: :post do
    resource.generate_invoice!
    redirect_to request.referer || resource_path, notice: 'Invoice has been Generated!'
  end

  action_item :payout_balance, only: :show do
    link_to 'Payout Balance', new_admin_vendor_payment_path(vendor_id: account.resource.id), method: :get if resource.resource_type == 'Vendor' && resource.balance.positive? && resource.resource.payment_methods.count.positive?
  end

  index do
    selectable_column
    id_column
    column :order
    column :resource
    column(:balance) { |a| a.balance.format }
    column :created_at
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :resource
          row(:balance) { |a| a.balance.format }
          row :order
        end
      end
    end

    columns do
      column do
        panel 'Transactions' do
          table_for account.transactions.find_each do
            column :id
            column :number
            column(:principal) { |a| a.principal.format }
            column(:fees) { |a| a.fees.format }
            column(:interest) { |a| a.interest.format }
            column(:status) do |o|
              status_tag(o.status, class: o.posted? ? 'orange' : 'red')
            end
            column(:type) do |o|
              status_tag(o.type, class: o.debit? ? 'ok' : 'red')
            end
            column :created_at
          end
        end
      end

      if account.try(:order)
        column do
          panel 'Payment Schedule' do
            table_for account.payment_schedule.payment_schedule_items do
              column :due_date
              column(:start_balance) { |s| s.start_balance.format }
              column(:payment) { |s| s.payment.format }
              column(:interest) { |s| s.interest.format }
              column(:fees) { |s| s.fees.format }
              column(:principal) { |s| s.principal.format }
              column(:end_balance)
              column('Invoice') do |r|
                link_to 'View', admin_invoice_path(r.invoice.id) if r.invoice.present?
              end
            end
          end
        end
      end
    end

    active_admin_comments
  end
end
