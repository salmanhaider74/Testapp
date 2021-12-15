ActiveAdmin.register Customer do
  menu priority: 3
  permit_params :name, :vendor_id, :duns_number, addresses_attributes: [:id, :street, :suite, :city, :state, :zip, :country, :is_default]
  actions :all, except: [:destroy]

  controller do
    def show
      @customer = Customer.includes(versions: :item).find(params[:id])
      @versions = @customer.versions
      @customer = @customer.versions[params[:version].to_i].reify if params[:version]
      show!
    end
  end

  index do
    selectable_column
    id_column
    column :number
    column :name
    column :vendor
    column :created_at
    actions
  end

  filter :name
  filter :number
  filter :vendor

  action_item :create_contact, only: :show do
    link_to 'Create Contact', new_admin_contact_path(customer_id: resource.id)
  end

  action_item :create_order, only: :show do
    link_to 'Create Order', new_admin_order_path(customer_id: resource.id)
  end

  member_action :generate_invoice, method: [:get, :post] do
    if request.get?
      render 'admin/invoices/generate_invoice'
    else
      redirect_to request.referer, flash: { error: 'Please Enter Valid Invoice Date!' } and return unless params[:generate_invoice][:invoice_date].present?

      success = resource.create_invoice!(Date.parse(params[:generate_invoice][:invoice_date])) || false

      if success
        redirect_to admin_customer_path(resource.id), notice: 'Invoice has been Generated!'
      else
        redirect_to admin_customer_path(resource.id), flash: { error: 'No Invoice has been Generated!' }
      end
    end
  end

  action_item :generate_invoice, only: :show do
    link_to 'Generate Invoice', generate_invoice_admin_customer_path(id: resource.id), method: :get if resource.accounts.count.positive?
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      if f.object.new_record?
        f.input :vendor, selected: params[:vendor_id]
      else
        f.input :vendor, input_html: { disabled: true }
      end
      f.input :name
      f.input :duns_number
      f.input :ein
      f.has_many :addresses, heading: 'Addresses', allow_destroy: true, new_record: true do |a|
        a.input :street
        a.input :suite
        a.input :city
        a.input :state
        a.input :zip
        a.input :country, as: :string
        a.input :is_default
      end
    end
    f.actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :vendor
          row :number
          row :name
          row :verified_at
          row :duns_number
          row :bin
          row :middesk_id
          row :ein
          row :entity_type
          row :bill_cycle_day
          row :created_at
          row :updated_at
          table_for customer.addresses.find_each do
            column :street
            column :suite
            column :city
            column :state
            column :zip
            column :country
            column :is_default
          end
        end

        panel 'Contacts' do
          table_for customer.contacts.find_each do
            column :id
            column :first_name
            column :last_name
            column :email
            column :phone
            column :primary
            column('') do |r|
              links = ''.html_safe
              links += link_to 'View', admin_contact_path(id: r.id, customer_id: resource.id)
              links += '&nbsp;&nbsp;-&nbsp;&nbsp;'.html_safe
              links += link_to 'Edit', edit_admin_contact_path(id: r.id, customer_id: resource.id)
              links += '&nbsp;&nbsp;-&nbsp;&nbsp;'.html_safe
              links += link_to 'Make Primary', make_primary_admin_contact_path(id: r.id, customer_id: resource.id), method: :put
              links
            end
          end
        end

        panel 'Documents' do
          table_for customer.documents.find_each do
            column :id
            column :order
            column :type
            column :personal_guaranntee
            column('Link') do |r|
              link_to 'Download', rails_blob_path(r.document, disposition: 'attachment')
            end
          end
        end

        panel 'Payment Methods' do
          table_for customer.payment_methods.find_each do
            column(:payment_mode) do |o|
              status_tag(o.payment_mode, class: (o.invoice? ? 'orange' : 'ok'))
            end
            column :is_default
            column :contact_name
            column :phone
            column :email
            column :bank
            column :account_name
            column :account_type
            column :routing_number
          end
        end
      end

      column do
        panel 'Orders' do
          paginated_collection(customer.orders.order('created_at DESC').page(params[:page]).per(10), download_links: false) do
            table_for collection do
              column :number
              column('View') do |r|
                link_to 'View', admin_order_path(r.id)
              end
              column :account
              column(:status) do |o|
                status_tag(o.status, class: (if o.declined?
                                               'declined'
                                             else
                                               (o.financed? ? 'ok' : 'orange')
                                             end).to_s)
              end
              column :amount
              column :start_date
            end
          end
        end

        panel 'Invoices' do
          paginated_collection(customer.invoices.order('created_at DESC').page(params[:page]).per(10), download_links: false) do
            table_for collection do
              column :number
              column('Link') do |r|
                link_to 'View', admin_invoice_path(r.id)
              end
              column(:amount) { |s| s.amount.format }
              column(:status) do |o|
                status_tag(o.status, class: (if o.paid?
                                               'ok'
                                             else
                                               (o.pending? ? 'orange' : 'red')
                                             end).to_s)
              end
              column :posted_date
              column :due_date
              column :invoice_date
              column :created_at
            end
          end
        end

        panel 'Payments' do
          paginated_collection(Payment.where(id: customer.invoices.map { |inv| inv.invoice_payments.map { |invp| invp.payment.id } }).order('created_at DESC').page(params[:page]).per(10), download_links: false) do
            table_for collection do
              column :number
              column('Link') do |r|
                link_to 'View', admin_payment_path(r.id)
              end
              column(:status) do |o|
                status_tag(o.status, class: (if o.processed?
                                               'ok'
                                             else
                                               (o.pending? ? 'orange' : 'red')
                                             end).to_s)
              end
              column(:amount) do |r|
                r.amount.format
              end
              column('External ID', &:external_id)
              column :created_at
              column :updated_at
            end
          end
        end

        active_admin_comments

        panel 'Versionate' do
          render partial: 'layouts/version', only: :show
        end
      end
    end
  end
end
