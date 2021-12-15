ActiveAdmin.register PaymentMethod do
  menu false
  permit_params :resource_id, :resource_type, :is_default, :account_name, :account_type, :account_number, :routing_number, :bank, :payment_mode, :contact_name, :phone, :email
  actions :new, :create, :show

  controller do
    before_action :vendor, only: :new
    rescue_from RuntimeError do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end

    def vendor
      @vendor = Vendor.find(params[:vendor_id]) unless params[:vendor_id].nil?
    end

    def new
      if @vendor.nil?
        redirect_to request.referer || resource_path, flash: { error: 'Vendor not found' }
        return
      end
      super
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :resource_id, input_html: { value: params[:vendor_id] }, as: :hidden
      f.input :resource_type, input_html: { value: 'Vendor' }, as: :hidden
      f.input :payment_mode, as: :select, collection: [['ACH', :ach], ['Invoice', :invoice]], include_blank: false, input_html: {
        onchange: "
            if (this.selectedOptions[0].innerHTML.includes('ACH')) {
              document.getElementById('payment_method_contact_name_input').style.display = 'none'
              document.getElementById('payment_method_phone_input').style.display = 'none'
              document.getElementById('payment_method_email_input').style.display = 'none'
              document.getElementById('payment_method_account_name_input').style.display = 'block'
              document.getElementById('payment_method_account_type_input').style.display = 'block'
              document.getElementById('payment_method_account_number_input').style.display = 'block'
              document.getElementById('payment_method_routing_number_input').style.display = 'block'
              document.getElementById('payment_method_bank_input').style.display = 'block'
            } else {
              document.getElementById('payment_method_contact_name_input').style.display = 'block'
              document.getElementById('payment_method_phone_input').style.display = 'block'
              document.getElementById('payment_method_email_input').style.display = 'block'
              document.getElementById('payment_method_account_name_input').style.display = 'none'
              document.getElementById('payment_method_account_type_input').style.display = 'none'
              document.getElementById('payment_method_account_number_input').style.display = 'none'
              document.getElementById('payment_method_routing_number_input').style.display = 'none'
              document.getElementById('payment_method_bank_input').style.display = 'none'
            }
          ",
      }
      f.input :bank
      f.input :account_name
      f.input :account_type, as: :select, collection: [['Checking', :checking], ['Savings', :savings]], include_blank: false
      f.input :account_number
      f.input :routing_number
      f.input :contact_name, wrapper_html: { style: 'display:none' }
      f.input :phone, wrapper_html: { style: 'display:none' }
      f.input :email, wrapper_html: { style: 'display:none' }
    end
    f.actions do
      f.action :submit
      f.cancel_link(request.referer)
    end
  end
end
