ActiveAdmin.register Payment do
  menu false
  actions :create, :new, :index, :show

  controller do
    before_action :invoice, only: :new
    rescue_from RuntimeError do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end

    def invoice
      @invoice = Invoice.find(params[:invoice_id]) unless params[:invoice_id].nil?
    end

    def new
      if @invoice.nil?
        redirect_to request.referer || resource_path, flash: { error: 'Invoice not found' }
        return
      end
      super
    end

    def create
      if params[:payment][:invoice_id].nil?
        redirect_to request.referer || resource_path, flash: { error: 'Invoice not found' }
      elsif params[:payment][:payment_method_id].empty?
        redirect_to request.referer || resource_path, flash: { error: 'Payment Method is required' }
      else
        invoice = Invoice.find(params[:payment][:invoice_id])
        invoice.charge!(params[:payment][:external_id], payment_method: PaymentMethod.find(params[:payment][:payment_method_id]), invoice_amount: params[:payment][:amount])
        redirect_to admin_invoice_path(params[:payment][:invoice_id]), notice: 'Payment Charged Successfully!'
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      show_external_id = invoice.customer.default_payment_method.invoice? ? 'display:block' : 'display:none'
      f.input :invoice_id, input_html: { value: params[:invoice_id] }, as: :hidden
      f.input :payment_method, as: :select, collection: invoice.customer.payment_methods.map { |pm| ["#{pm.is_default? ? 'Default - ' : ''} #{pm.invoice? ? "[Invoice] #{pm.contact_name} #{pm.phone} #{pm.email}" : "[#{pm.payment_mode}] #{pm.bank} #{pm.account_name} #{pm.account_type}"}", pm.id] }, include_blank: false, input_html: {
        onchange: "
          if (this.selectedOptions[0].innerHTML.includes('ACH')) {
            document.getElementById('payment_external_id_input').style.display = 'none'
          } else {
            document.getElementById('payment_external_id_input').style.display = 'block'
          }
        ",
      }, selected: invoice.customer.default_payment_method.try(:id)
      f.input :amount, input_html: { value: Money.new(invoice.amount_cents - invoice.invoice_payments.map { |p| p.payment.amount_cents }.inject(0, &:+)) }
      f.input :external_id, label: 'External ID', wrapper_html: { style: show_external_id }
    end
    f.actions
  end
end
