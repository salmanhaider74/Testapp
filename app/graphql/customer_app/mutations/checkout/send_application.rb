module CustomerApp::Mutations
  class Checkout::SendApplication < BaseMutation
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :phone, String, required: true

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        Contact.transaction do
          contact = Contact.find_or_initialize_by(attributes.merge(customer: current_customer, role: :owner_officer))
          contact.save!
          contact.make_primary!

          session = Session.find_or_initialize_by(resource: contact, order_id: current_order.id, expires_at: 3.days.from_now)
          session.save!

          ContactMailer.with({
            contact: session.resource,
            session: session,
          }).order_application.deliver_later

          current_order.update!(application_sent: true)
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
