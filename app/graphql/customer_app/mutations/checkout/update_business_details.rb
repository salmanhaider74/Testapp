module CustomerApp::Mutations
  class Checkout::UpdateBusinessDetails < BaseMutation
    argument :name, String, required: true
    argument :street, String, required: true
    argument :suite, String, required: false
    argument :city, String, required: true
    argument :state, String, required: true
    argument :zip, String, required: true
    argument :country, String, required: false
    argument :duns_number, String, required: true
    argument :ein, String, required: true
    argument :entity_type, String, required: true
    argument :date_started, GraphQL::Types::ISO8601Date, required: true

    type Common::Types::SessionType

    def resolve(attributes)
      authenticated do
        Customer.transaction do
          default_address = Address.find_or_initialize_by(id: current_customer.default_address_id)
          default_address.update!(attributes.slice(*ADDRESS_ATTRIBUTES).merge(resource: current_customer))
          current_session.contact.customer.update!(attributes.except(*ADDRESS_ATTRIBUTES).merge(reviewed: true))
          current_order.underwrite!(current_contact)
        end
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
