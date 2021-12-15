ActiveAdmin.register Payment, as: 'VendorPayment' do
  menu false
  actions :create, :new, :index, :show

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

    def create
      if params[:payment][:vendor_id].nil?
        redirect_to request.referer || resource_path, flash: { error: 'Vendor not found' }
      elsif params[:payment][:payment_method_id].empty?
        redirect_to request.referer || resource_path, flash: { error: 'Payment Method is required' }
      else
        vendor = Vendor.find(params[:payment][:vendor_id])
        vendor.payout!(params[:payment][:external_id], payment_method: PaymentMethod.find(params[:payment][:payment_method_id]), balance_amount: params[:payment][:amount])
        redirect_to admin_vendor_path(params[:payment][:vendor_id]), notice: 'Payment Charged Successfully!'
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      show_external_id = vendor.default_payment_method.present? && vendor.default_payment_method.invoice? ? 'display:block' : 'display:none'
      f.input :vendor_id, input_html: { value: params[:vendor_id] }, as: :hidden
      f.input :payment_method, as: :select, collection: vendor.payment_methods.map { |pm| ["#{pm.is_default? ? 'Default - ' : ''} #{pm.payment_mode.invoice? ? "[Invoice] #{pm.contact_name} #{pm.phone} #{pm.email}" : "[#{pm.payment_mode}] #{pm.bank} #{pm.account_name} #{pm.account_type}"}", pm.id] }, include_blank: false, input_html: {
        onchange: "
            if (this.selectedOptions[0].innerHTML.includes('ACH')) {
              document.getElementById('payment_external_id_input').style.display = 'none'
            } else {
              document.getElementById('payment_external_id_input').style.display = 'block'
            }
          ",
      }, selected: vendor.default_payment_method.try(:id)
      f.input :amount, input_html: { value: Money.new(vendor.account.balance_cents) }
      f.input :external_id, label: 'External ID', wrapper_html: { style: show_external_id }
    end
    f.actions
  end
end
