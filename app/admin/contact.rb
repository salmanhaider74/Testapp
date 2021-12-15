ActiveAdmin.register Contact do
  menu false

  permit_params :customer_id, :first_name, :last_name, :email, :phone
  actions :show, :new, :create, :update, :edit, :index

  filter :customer
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  controller do
    def show
      @contact = Contact.includes(versions: :item).find(params[:id])
      @versions = @contact.versions
      @contact = @contact.versions[params[:version].to_i].reify if params[:version]
      show!
    end
  end

  member_action :make_primary, method: :put do
    resource.make_primary!
    redirect_to request.referer || resource_path
  end

  member_action :remove_personal_guarantee, method: :delete do
    redirect_to request.referer || resource_path, notice: 'Guarantee removed!' if resource.personal_guarantees.find_by_id(params['personal_guarantee_id']).destroy!
  end

  action_item :make_primary_contact, only: :show do
    link_to 'Make Primary Contact', make_primary_admin_contact_path(id: resource.id), method: :put unless resource.primary?
  end

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone
    column :role
    column :is_default
    column :created_at
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      if f.object.new_record?
        f.input :customer, selected: params[:customer_id]
      else
        f.input :customer, input_html: { disabled: true }
      end
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
    end
    f.actions do
      f.action :submit
      f.cancel_link(request.referer)
    end
  end

  show do
    columns do
      column do
        attributes_table do
          row :customer
          row :first_name
          row :last_name
          row :email
          row :phone
          row :role
          row :primary
          row :created_at
          row :updated_at
          table_for contact.addresses.find_each do
            column :street
            column :suite
            column :city
            column :state
            column :zip
            column :country
            column :is_default
          end
        end
      end
      column do
        panel 'Versionate' do
          render partial: 'layouts/version', only: :show
        end

        panel 'Personal Guarantees' do
          table_for contact.personal_guarantees.find_each do
            column :id
            column :order
            column :accepted_at
            column('') do |r|
              links = ''.html_safe
              links += link_to 'Remove', remove_personal_guarantee_admin_contact_path(id: resource.id, personal_guarantee_id: r.id), method: :delete
              links
            end
          end
        end
      end
    end
  end
end
