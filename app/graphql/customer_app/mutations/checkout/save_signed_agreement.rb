module CustomerApp::Mutations
  class Checkout::SaveSignedAgreement < BaseMutation
    type Common::Types::SessionType

    def resolve
      authenticated do
        current_order.update!(status: 'agreement')
        current_order.underwrite!(current_contact)
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    end
  end
end
