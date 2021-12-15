ActiveAdmin.register Order do
  menu priority: 4

  permit_params :amount, :customer_id, :start_date, :end_date, :term, :interest_percentage, :interest_subsidy_percentage, :start_date_validation, :status, :financial_details, order_items_attributes: [:id, :name, :description, :order_id, :quantity, :unit_price, :_destroy]

  actions :all, except: [:destroy]

  member_action :order_status, method: :put do
    resource.update!(status: params[:status], manual_review: false)
    resource.underwrite!(resource.customer.primary_contact)
    redirect_to request.referer || resource_path, notice: "Moved to #{params[:status].titleize} state!"
  end

  member_action :order_send_application, method: :put do
    resource.send_application!
    redirect_to request.referer || resource_path, notice: 'Application Sent!'
  end

  member_action :finance, method: :put do
    resource.finance!
    redirect_to request.referer || resource_path, notice: 'Order Financed!'
  end

  member_action :checkout_order, method: :put do
    resource.checkout!
    redirect_to request.referer || resource_path, notice: 'Moved to checkout!'
  end

  member_action :order_loan_decision, method: :put do
    resource.update!(loan_decision: params[:status], manual_review: params[:status] == 'approved')
    resource.underwrite!(resource.customer.primary_contact)
    redirect_to request.referer || resource_path, notice: "Order #{params[:status].titleize}!"
  end

  member_action :remove_personal_guarantee, method: :delete do
    redirect_to request.referer || resource_path, notice: 'Guarantee removed!' if resource.personal_guarantees.find_by_id(params['personal_guarantee_id']).destroy!
  end

  member_action :pull_middesk, method: :post do
    resource.pull_middesk
    redirect_to request.referer || resource_path, notice: 'Middesk info reterival started!'
  end

  member_action :add_financial_details, method: [:get, :post] do
    if request.get?
      @order = resource
    else
      resource.update(params[:order].permit!)
      redirect_to admin_order_path, notice: 'Financial Details updated on Order!'
    end
  end

  action_item :full_check, only: :show do
    link_to 'Move to Fullcheck', order_status_admin_order_path(customer_id: order.customer_id, id: order.id, status: 'fullcheck'), method: :put if order.pending? && !order.frozen? && order.precheck? && order.manual_review
  end

  action_item :application, only: :show do
    link_to 'Move to Application', order_status_admin_order_path(customer_id: order.customer_id, id: order.id, status: 'application'), method: :put if order.pending? && !order.frozen? && order.fullcheck? && order.manual_review && order.fullcheck_consent
  end

  action_item :financial_details, only: :show do
    link_to 'Add Financial Details', add_financial_details_admin_order_path(id: order.id) if order.pending? && !order.frozen? && order.application? && order.documents_complete?
  end

  action_item :finance_order, only: :show, if: proc { resource.agreement? && resource.vendor.present? && resource.document_of_type?(:funding_invoice) } do
    link_to 'Finance Order', finance_admin_order_path(customer_id: order.customer_id, id: order.id), method: :put
  end

  action_item :upload_document, only: :show do
    link_to 'Upload Document', new_admin_order_document_path(customer_id: order.customer_id, order_id: order.id)
  end

  action_item :checkout_order, only: :show do
    link_to 'Checkout Order', checkout_order_admin_order_path(customer_id: order.customer_id, id: order.id), method: :put if order.approved? && !order.checkout? && !order.agreement? && !order.financed? && order.order_items.count.positive?
  end

  action_item :approve_order, only: :show do
    link_to 'Approve Order', order_loan_decision_admin_order_path(customer_id: order.customer_id, id: order.id, status: 'approved'), method: :put, data: { confirm: 'Are you sure you want to approve this?' } if order.manual_review && !%w[approved declined].include?(order.loan_decision) && order.suggested_loan_decision == 'approved'
  end

  action_item :decline_order, only: :show do
    link_to 'Decline Order', order_loan_decision_admin_order_path(customer_id: order.customer_id, id: order.id, status: 'declined'), method: :put, data: { confirm: 'Are you sure you want to decline this?' } if order.manual_review && !%w[approved declined].include?(order.loan_decision)
  end

  action_item :pull_middesk, only: :show do
    link_to 'Pull Middesk', pull_middesk_admin_order_path(id: resource.id), method: :post if resource.customer.default_address.present? && !resource.document_of_type?(:middesk) && !order.approved?
  end

  controller do
    rescue_from RuntimeError do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end
  end

  index do
    selectable_column
    id_column
    column :number
    column(:stage) do |o|
      status_tag(o.status, class: o.financed? ? 'ok' : 'orange')
    end
    column(:loan_decision) do |o|
      status_tag(o.loan_decision, class: (if o.declined?
                                            'declined'
                                          else
                                            (o.approved? ? 'ok' : 'orange')
                                          end).to_s)
    end
    column(:amount) do |o|
      o.amount.format
    end
    column :start_date
    column(:term) do |o|
      "#{o.term.round(2)} #{o.term > 1 ? 'month'.pluralize : 'month'}"
    end
    column :customer
    column('Vendor') do |o|
      o.customer.vendor
    end
    column :created_at
    actions
  end

  filter :vendor
  filter :number
  filter :start_date
  filter :created_at

  scope('With Form') { |scope| scope.where(has_form: true) }
  scope('Pending') { |scope| scope.where(loan_decision: 'pending') }
  scope('Declined') { |scope| scope.where(loan_decision: 'declined') }
  scope('Approved') { |scope| scope.where(loan_decision: 'approved') }
  scope :credit_review
  scope :ops_review
  scope('Financed') { |scope| scope.where(status: 'financed') }
  scope('Manual Review') { |scope| scope.where(manual_review: true) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :customer, selected: params[:customer_id] if f.object.new_record?
      f.input :amount
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :interest_subsidy_percentage, label: 'Interest Rate Subsidy (%)'
      f.input :start_date_validation, input_html: { value: 'true' }, as: :hidden
      f.has_many :order_items, heading: 'Order Items', allow_destroy: true, new_record: true do |a|
        a.input :name
        a.input :description
        a.input :quantity
        a.input :unit_price
      end
    end
    f.actions
  end

  show do
    columns do
      column do
        attributes_table title: 'Loan Decision' do
          row(:loan_decision) do |o|
            status_tag(o.loan_decision, class: (if o.declined?
                                                  'declined'
                                                else
                                                  (o.approved? ? 'ok' : 'orange')
                                                end).to_s)
          end
          row(:suggested_loan_decision) do |o|
            status_tag(o.suggested_loan_decision, class: (if o.suggested_loan_decision == 'declined'
                                                            'declined'
                                                          else
                                                            (o.suggested_loan_decision == 'approved' ? 'ok' : 'orange')
                                                          end).to_s)
          end
          row :vartana_score
          row :vartana_rating
          row(:credit_limit) { |o| o.credit_limit.format }
          row :manual_review
          row :fullcheck_consent
        end

        attributes_table do
          row :number
          row('Vendor') do |o|
            o.customer.vendor
          end
          row :customer
          row(:status) do |o|
            status_tag(o.status, class: o.financed? ? 'ok' : 'orange')
          end
          row(:bill_cycle_day) { |r| r.customer.bill_cycle_day }
          row :approved_at
          row :declined_at
          row('Agreement') do |s|
            link_to 'Download', rails_blob_path(s.agreement, disposition: 'attachment') if s.agreement.present?
          end
          row :created_at
        end

        attributes_table title: 'Financial Details' do
          row :account
          row(:amount) { |s| s.amount.format }
          row(:payment) { |s| s.payment.format }
          row :billing_frequency
          row('Period') do |o|
            "[#{o.start_date} - #{o.end_date} (#{o.term.round(2)} #{o.term > 1 ? 'month'.pluralize : 'month'})]"
          end
          row(:interest_rate) { |r| number_to_percentage(r.interest_rate * 100, precision: 2, locale: :en) }
          row(:interest_rate_subsidy) { |r| number_to_percentage(r.interest_rate_subsidy * 100, precision: 2, locale: :en) }
          row(:interest) { |s| s.interest.format }
          row('Vendor Advance') do |o|
            "[#{o.advance.format} (#{o.discount.format})]"
          end
        end

        panel 'Order Items' do
          table_for order.order_items.find_each do
            column :number
            column :name
            column :description
            column(:unit_price) { |s| s.unit_price.format }
            column :quantity
            column(:amount) { |s| s.amount.format }
          end
        end

        panel 'Personal Guarantees' do
          table_for order.personal_guarantees.find_each do
            column :id
            column :contact
            column :accepted_at
            column('') do |r|
              links = ''.html_safe
              links += link_to 'Remove', remove_personal_guarantee_admin_order_path(id: resource.id, personal_guarantee_id: r.id), method: :delete
              links
            end
          end
        end
      end

      column span: 2 do
        render partial: 'steps', locals: { order: resource } unless resource.financed?

        if resource.documents.count.positive?
          tabs do
            order.documents.each_with_index do |doc, idx|
              tab "Document #{idx + 1} - #{doc.type}" do
                if doc.pdf?
                  render partial: 'document', locals: { document: doc }
                else
                  link_to 'Download', rails_blob_path(doc.document, disposition: 'attachment')
                end
              end
            end
          end
        end

        if resource.financial_details != {}
          attributes_table title: 'Financial Information' do
            row(:annual_revenue) { |s| s.annual_revenue.format }
            row(:annual_net_operating_income) { |s| s.annual_net_operating_income.format }
            row(:annual_debt_service) { |s| s.annual_debt_service.format }
            row('Annual Debt Service (Vartana)') { |s| s.payment.format }
            row(:dscr, &:dscr)
          end
        end

        active_admin_comments

        panel 'Payment Schedule' do
          table_for order.schedule do
            column :period
            column :start_date
            column :end_date
            column(:start_balance) { |s| s.start_balance.format }
            column(:payment) { |s| s.payment.format }
            column(:interest) { |s| s.interest.format }
            column(:fees) { |s| s.fees.format }
            column(:principal) { |s| s.principal.format }
            column(:end_balance) { |s| s.end_balance.zero? ? Money.new(0, 'USD').format : s.end_balance.format }
          end
        end
      end
    end
  end
end
