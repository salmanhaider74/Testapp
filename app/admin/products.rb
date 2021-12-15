ActiveAdmin.register Product do
  menu false
  permit_params :name, :vendor_id, :min_interest_rate_subsidy_percentage, :max_interest_rate_subsidy_percentage, :min_initial_loan_amount, :min_subsequent_loan_amount, :max_loan_amount, :pricing_schema
  actions :all, except: [:destroy]

  member_action :toggle_product_status, method: :put do
    resource.update!(is_active: params[:status])
    redirect_to request.referer || resource_path, notice: "Product #{params[:status] == 'true' ? 'Activated' : 'Deactivated'}!"
  end

  action_item :toggle_status, only: :show do
    link_to "#{product.is_active ? 'Deactivate' : 'Activate'} Product", toggle_product_status_admin_product_path(id: product.id, status: !product.is_active), method: :put
  end

  controller do
    rescue_from StandardError do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end
  end

  show do
    attributes_table do
      row :vendor
      row :number
      row :name
      row :is_active
      row(:min_interest_rate_subsidy) do |o|
        "#{(o.min_interest_rate_subsidy * 100).round(2)}%"
      end
      row(:max_interest_rate_subsidy) do |o|
        "#{(o.max_interest_rate_subsidy * 100).round(2)}%"
      end
      row(:min_initial_loan_amount) do |o|
        o.min_initial_loan_amount.format
      end
      row(:min_subsequent_loan_amount) do |o|
        o.min_subsequent_loan_amount.format
      end
      row(:max_loan_amount) do |o|
        o.max_loan_amount.format
      end
      row(:blended_rate) do |model|
        tag.pre JSON.pretty_generate(model.blended_rate)
      end
      row :pricing_schema do |model|
        tag.pre JSON.pretty_generate(model.pricing_schema)
      end
      row :created_at
      row :updated_at
    end
  end

  form html: { class: 'validations' } do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.object.pricing_schema = f.object.new_record? ? JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json'))).to_json : f.object.pricing_schema.to_json
    f.inputs do
      if f.object.new_record?
        f.input :vendor, selected: params[:vendor_id]
      else
        f.input :vendor, input_html: { disabled: true }
      end
      f.input :name
      f.input :min_interest_rate_subsidy_percentage, label: 'Minimum Interest Rate Subsidy (%)'
      f.input :max_interest_rate_subsidy_percentage, label: 'Maximum Interest Rate Subsidy (%)'
      f.input :min_initial_loan_amount
      f.input :min_subsequent_loan_amount
      f.input :max_loan_amount
      f.input :pricing_schema, as: :text, wrapper_html: { tag: 'pre' }
    end
    f.actions
  end
end
