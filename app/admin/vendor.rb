ActiveAdmin.register Vendor do
  menu priority: 2

  permit_params :name, :domain, :ein, :logo, :favicon, :contact_email, :order_declined_email, :order_financed_email, :agreement_signed_need_invoice_email, :checkout_ready_email, :need_sales_order_email, :need_financial_review_email, :not_approved_require_fullcheck_email, :pre_approved_email, addresses_attributes: [:id, :street, :suite, :city, :state, :zip, :country, :is_default, :_destroy]
  actions :all, except: [:destroy]

  index do
    selectable_column
    id_column
    column :number
    column :name
    column :created_at
    actions
  end

  action_item :create_product, only: :show do
    link_to 'Create Product', new_admin_product_path(vendor_id: resource.id)
  end

  action_item :create_customer, only: :show do
    link_to 'Create Customer', new_admin_customer_path(vendor_id: resource.id)
  end

  action_item :create_payment_method, only: :show do
    link_to 'Create Payment Method', new_admin_payment_method_path(vendor_id: resource.id)
  end

  action_item :create_user, only: :show do
    link_to 'Create User', new_admin_user_path(vendor_id: resource.id)
  end

  action_item :set_email_preferences, only: :show do
    link_to 'Email Preferences', edit_admin_vendor_path(email_preferences: true)
  end

  member_action :toggle_test_mode, method: :put do
    resource.update!(test_mode: params[:status])
    redirect_to request.referer || resource_path, notice: "Vendor Test Mode #{params[:status] == 'true' ? 'Enabled' : 'Disabled'}!"
  end

  action_item :toggle_status, only: :show do
    link_to "#{vendor.test_mode ? 'Disable' : 'Enable'} Test Mode", toggle_test_mode_admin_vendor_path(id: vendor.id, status: !vendor.test_mode), method: :put
  end

  filter :name
  filter :number

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      if params[:email_preferences] == 'true'
        f.input :pre_approved_email, as: :boolean
        f.input :not_approved_require_fullcheck_email, as: :boolean
        f.input :need_financial_review_email, as: :boolean
        f.input :need_sales_order_email, as: :boolean
        f.input :checkout_ready_email, as: :boolean
        f.input :agreement_signed_need_invoice_email, as: :boolean
        f.input :order_financed_email, as: :boolean
        f.input :order_declined_email, as: :boolean
      else
        f.input :name
        f.input :domain
        f.input :ein
        f.input :contact_email
        f.input :logo, as: :file
        f.input :favicon, as: :file
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
    end
    f.actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :name
          row :number
          row :test_mode
          row :account
          row :domain
          row :contact_email
          row :favicon do |v|
            image_tag(rails_blob_path(v.favicon, disposition: 'logo'), height: 50) if v.favicon.attached?
          end
          row :logo do |v|
            image_tag(rails_blob_path(v.logo, disposition: 'logo'), height: 50) if v.logo.attached?
          end
          row :created_at
          row :updated_at
          table_for vendor.addresses.find_each do
            column :street
            column :suite
            column :city
            column :state
            column :zip
            column :country
            column :is_default
          end
        end

        attributes_table title: 'Email Preferences' do
          row :pre_approved_email
          row :checkout_ready_email
          row :order_financed_email
          row :order_declined_email
          row :need_sales_order_email
          row :need_financial_review_email
          row :agreement_signed_need_invoice_email
          row :not_approved_require_fullcheck_email
        end
      end

      column do
        panel 'Payment Methods' do
          table_for vendor.payment_methods.find_each do
            column('Link') do |r|
              link_to 'View', admin_payment_method_path(r.id)
            end
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

        panel 'Payments' do
          paginated_collection(vendor.payments.order('created_at DESC').page(params[:page]).per(10), download_links: false) do
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

        panel 'Products' do
          paginated_collection(vendor.products.order('created_at DESC').page(params[:page]).per(10), download_links: false) do
            table_for collection do
              column :number
              column('Link') do |r|
                link_to 'View', admin_product_path(r.id)
              end
              column(:is_active) do |o|
                status_tag(o.is_active, class: (o.is_active ? 'ok' : 'red'))
              end
              column :name
              column :created_at
              column :updated_at
            end
          end
        end
      end
    end

    panel 'Customers' do
      table_for vendor.customers.find_each do
        column :id
        column :number
        column('Name') do |r|
          links = ''.html_safe
          links += link_to r.name, admin_customer_path(id: r.id)
          links
        end
        column :duns_number
        column :ein
        column :entity_type
      end
    end

    panel 'Users' do
      table_for vendor.users.find_each do
        column('View') do |r|
          links = ''.html_safe
          links += link_to 'View', admin_user_path(id: r.id)
          links
        end
        column :first_name
        column :last_name
        column :email
        column :phone
      end
    end
    active_admin_comments
  end
end
