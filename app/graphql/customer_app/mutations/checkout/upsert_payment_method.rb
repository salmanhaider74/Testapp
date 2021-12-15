module CustomerApp::Mutations
  class Checkout::UpsertPaymentMethod < BaseMutation
    argument :id, ID, required: false
    argument :payment_mode, String, required: true
    argument :bank, String, required: false
    argument :account_name, String, required: false
    argument :account_type, String, required: false
    argument :routing_number, String, required: false
    argument :account_number, String, required: false
    argument :contact_name, String, required: false
    argument :phone, String, required: false
    argument :email, String, required: false
    argument :street, String, required: false
    argument :suite, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :zip, String, required: false
    argument :country, String, required: false

    type Common::Types::SessionType

    def resolve(attributes)
      authenticated do
        PaymentMethod.transaction do
          payment_method = PaymentMethod.find_or_initialize_by(id: attributes[:id])
          if payment_method.id.nil?
            payment_method.update!(attributes.except(:id, *ADDRESS_ATTRIBUTES).merge(addresses_attributes: [attributes.slice(*ADDRESS_ATTRIBUTES)], resource: current_customer))
          else
            default_address = Address.find_or_initialize_by(id: current_customer.default_address_id)
            default_address.update!(attributes.slice(*ADDRESS_ATTRIBUTES).merge(resource: current_customer))
            payment_method.update!(attributes.except(:id, *ADDRESS_ATTRIBUTES).merge(resource: current_customer))
          end
          current_order.underwrite!(current_contact)
          current_session.reload
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
