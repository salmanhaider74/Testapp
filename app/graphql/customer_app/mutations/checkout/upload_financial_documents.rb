module CustomerApp::Mutations
  class Checkout::UploadFinancialDocuments < BaseMutation
    argument :tax_returns, [ApolloUploadServer::Upload], required: true
    argument :bank_statements, [ApolloUploadServer::Upload], required: true

    type Common::Types::SessionType

    def resolve(input)
      save_document = lambda do |file, document_type, customer, order|
        if file.present?
          blob = ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: file.original_filename,
            content_type: file.content_type
          )
          Document.transaction do
            Document.create!(order_id: order.id, customer_id: customer.id, type: document_type, document: blob)
          end
        else
          GraphQL::ExecutionError.new('File not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
        end
      end

      authenticated do
        input[:tax_returns].each do |file|
          save_document.call(file, :tax_return, current_customer, current_order)
        end
        input[:bank_statements].each do |file|
          save_document.call(file, :bank_statement, current_customer, current_order)
        end

        current_order.underwrite!(current_contact)
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
