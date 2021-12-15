module CustomerApp::Mutations
  class Checkout::DestroyOwner < BaseMutation
    argument :id, ID, required: true

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        Contact.transaction do
          contact = Contact.find_by!(id: attributes[:id], primary: false)
          contact.update!(deleted_at: Time.now)
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
