module CustomerApp::Mutations
  ADDRESS_ATTRIBUTES = [:street, :city, :suite, :state, :zip, :country].freeze

  class Checkout::UpdatePersonalDetails < BaseMutation
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :ownership, Float, required: false
    argument :phone, String, required: true
    argument :role, String, required: false
    argument :ssn, String, required: false
    argument :dob, GraphQL::Types::ISO8601Date, required: false
    # argument :street, String, required: true
    # argument :suite, String, required: false
    # argument :city, String, required: true
    # argument :state, String, required: true
    # argument :zip, String, required: true
    argument :country, String, required: false
    argument :is_owner, Boolean, required: false

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        Contact.transaction do
          role = attributes[:is_owner] ? :owner_officer : :other
          role = attributes[:role] if attributes[:role].present?
          # default_address = Address.find_or_initialize_by(id: current_contact.default_address_id)
          # default_address.update!(attributes.slice(*ADDRESS_ATTRIBUTES).merge(resource: current_contact))
          current_contact.update!(attributes.except(:is_owner).merge(role: role, reviewed: true))
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
