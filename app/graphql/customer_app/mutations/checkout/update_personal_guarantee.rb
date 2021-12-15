module CustomerApp::Mutations
  class Checkout::UpdatePersonalGuarantee < BaseMutation
    argument :agreed, Boolean, required: true
    argument :ssn, String, required: true
    argument :dob, GraphQL::Types::ISO8601Date, required: true

    type Common::Types::SessionType

    def resolve(input)
      authenticated do
        if input[:agreed]
          PersonalGuarantee.transaction do
            personal_guarantee = PersonalGuarantee.find_or_initialize_by(contact_id: current_contact.id, order_id: current_order.id)
            contact = Contact.where(id: current_contact.id)
            personal_guarantee.update!(accepted_at: Time.now) if personal_guarantee.present?
            contact.update(ssn: input[:ssn], dob: input[:dob])
            current_order.underwrite!(current_contact)
            current_session.reload
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
