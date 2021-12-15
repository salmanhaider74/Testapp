ActiveAdmin.register User do
  menu false
  permit_params :vendor_id, :first_name, :last_name, :email, :phone, :password
  actions :show, :new, :create, :update, :edit, :index

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      if f.object.new_record?
        f.input :vendor, selected: params[:vendor_id]
      else
        f.input :vendor, input_html: { disabled: true }
      end
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone
      f.input :password
    end
    f.actions do
      f.action :submit
      f.cancel_link(request.referer)
    end
  end
end
