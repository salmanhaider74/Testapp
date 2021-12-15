module CustomerApp::Mutations
  class Checkout::UpdateContactVerificationStatus < BaseMutation
    type Common::Types::SessionType

    def resolve
      authenticated do
        contact = Contact.find_by(id: current_contact.id)
        current_order.underwrite!(current_contact) if contact.inquiry_completed?
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
