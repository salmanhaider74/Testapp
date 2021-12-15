module CustomerApp::Mutations
  class Checkout::CreateOwners < BaseMutation
    argument :owners, [CustomerApp::Types::OwnerInput], required: true

    type Common::Types::SessionType

    def resolve(owners:)
      authenticated do
        Contact.transaction do
          owners.each do |owner|
            contact = Contact.find_or_initialize_by(id: owner.id)
            if contact.id.nil?
              contact.update!(owner.to_h.except(:id, *ADDRESS_ATTRIBUTES).merge(addresses_attributes: [owner.to_h.slice(*ADDRESS_ATTRIBUTES)], customer: current_customer))
            else
              default_address = Address.find_or_initialize_by(id: current_customer.default_address_id)
              default_address.update!(owner.to_h.slice(*ADDRESS_ATTRIBUTES).merge(resource: current_customer))
              contact.update!(owner.to_h.except(:id, *ADDRESS_ATTRIBUTES).merge(customer: current_customer))
            end
          end
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
