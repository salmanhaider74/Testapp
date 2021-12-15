module CustomerApp::Mutations
  class Checkout::UnderwriteOwner < BaseMutation
    argument :application_sent, Boolean, required: true

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        if attributes[:application_sent]
          Session.transaction do
            primary_contact = Contact.find_by(customer: current_customer, role: :owner_officer, primary: true)

            if primary_contact.present?
              session = Session.find_by(resource: current_contact, order_id: current_order.id)
              session.destroy!

              current_order.underwrite!(primary_contact)
              current_order.update!(application_sent: false)
            end
          end
        end
        current_session
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
