ActiveAdmin.register Document do
  actions :all, except: [:destroy, :edit, :update]

  permit_params :customer_id, :type, :document

  belongs_to :order

  controller do
    rescue_from RuntimeError do |exception|
      redirect_to request.referer || resource_path, flash: { error: exception.message }
    end

    def create
      create! do |format|
        format.html { redirect_to admin_order_path(params[:order_id]), notice: 'Document Uploaded!' }
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :customer_id, input_html: { value: params[:customer_id] }, as: :hidden
      f.input :type
      f.input :document, as: :file
    end
    f.actions
  end
end
