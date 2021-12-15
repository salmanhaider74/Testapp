ActiveAdmin.register Invoice do
  menu priority: 5

  actions :all, except: [:destroy, :create, :edit, :new, :edit]

  member_action :email_invoice, method: :put do
    resource.email_invoice
    redirect_to request.referer || resource_path, notice: 'Invoice Sent Successfully!'
  end

  action_item :email_invoice, only: :show do
    link_to 'Email Invoice', email_invoice_admin_invoice_path(id: invoice.id), method: :put unless invoice.paid?
  end

  member_action :charge_invoice, method: :put do
    resource.charge!
    redirect_to request.referer || resource_path, notice: 'Invoice Charged Successfully!'
  end

  action_item :charge_invoice, only: :show do
    link_to 'Charge Invoice', new_admin_payment_path(invoice_id: resource.id) if invoice.pending? && invoice.customer.payment_methods.count.positive?
  end

  member_action :post_invoice, method: :put do
    resource.post!
    redirect_to request.referer || resource_path, notice: 'Invoice Posted Successfully!'
  end

  action_item :post_invoice, only: :show do
    link_to 'Post Invoice', post_invoice_admin_invoice_path(id: resource.id), method: :put unless invoice.paid? || invoice.pending?
  end

  member_action :delete_invoice, method: :delete do
    resource.destroy!
    redirect_to admin_invoices_path, notice: 'Invoice Deleted Successfully!'
  end

  action_item :delete_invoice, only: :show do
    link_to 'Delete Invoice', delete_invoice_admin_invoice_path(id: resource.id), method: :delete if invoice.draft?
  end

  controller do
    rescue_from ActiveRecord::RecordInvalid do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end
  end

  index do
    selectable_column
    id_column
    column :number
    column(:amount) { |s| s.amount.format }
    column(:status) do |s|
      status_tag(s.status, class: (if s.paid?
                                     'ok'
                                   else
                                     (s.pending? ? 'orange' : 'yellow')
                                   end).to_s)
    end
    column :posted_date
    column :due_date
    column :created_at
  end

  filter :customer
  filter :due_date
  filter :posted_date

  scope('Draft') { |scope| scope.where(status: 'draft') }
  scope('Pending') { |scope| scope.where(status: 'pending') }
  scope('Paid') { |scope| scope.where(status: 'paid') }
  scope('Due') { |scope| scope.where(due_date: Date.today) }
  scope('Upcoming') { |scope| scope.where('due_date < ?', Date.today) }
  scope('Late') { |scope| scope.where('due_date > ?', Date.today) }

  show do
    columns do
      column do
        attributes_table do
          row :customer
          row(:amount) { |s| s.amount.format }
          row(:status) do |s|
            status_tag(s.status, class: (if s.paid?
                                           'ok'
                                         else
                                           (s.pending? ? 'orange' : 'yellow')
                                         end).to_s)
          end
          row :posted_date
          row :due_date
          row :created_at
          row('PDF') do |s|
            link_to 'Download', rails_blob_path(s.pdf, disposition: 'attachment') if s.pdf.present?
          end
        end
      end

      column do
        panel 'Invoice Items' do
          paginated_collection(InvoiceItem.where(invoice: invoice).order('created_at DESC').page(params[:page]).per(10), download_links: false) do
            table_for collection do
              column :id
              column :number
              column('Account') do |r|
                link_to 'Account', admin_account_path(r.payment_schedule_item.account.id)
              end
              column :order_item
              column :name
              column :description
              column(:amount) { |s| s.amount.format }
              column(:amount_charged) { |s| s.amount_charged.format }
            end
          end
        end
      end
    end

    panel 'Payments' do
      table_for invoice.invoice_payments.find_each do
        column('Number') { |s| s.payment.number }
        column('Amount') { |s| s.payment.amount.format }
        column(:status) do |s|
          status_tag(s.payment.status, class: (if s.payment.processed?
                                                 'ok'
                                               else
                                                 (s.payment.pending? ? 'orange' : 'Red')
                                               end).to_s)
        end
        column('Error') { |s| s.payment.error_message }
        column('External ID') { |s| s.payment.external_id }
        column('Created At') { |s| s.payment.created_at }
        column('Updated At') { |s| s.payment.updated_at }
      end
    end

    active_admin_comments
  end
end
