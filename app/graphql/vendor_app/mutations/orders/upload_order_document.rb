module VendorApp::Mutations
  class Orders::UploadOrderDocument < BaseMutation
    argument :order_id, ID, required: true
    argument :document_type, String, required: true
    argument :document, ApolloUploadServer::Upload, required: true

    type Common::Types::OrderType

    def resolve(**attributes)
      authenticated do
        file = attributes[:document]
        if file.present?
          blob = ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: file.original_filename,
            content_type: file.content_type
          )
          Document.transaction do
            current_vendor.orders.find(attributes[:order_id]).tap do |order|
              Document.create!(order_id: order.id, customer_id: order.customer.id, type: attributes[:document_type], document: blob)
              order.update!(has_form: true)
            end
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
