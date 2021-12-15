module VendorApp::Mutations
  class Orders::GrantFullcheckConsent < BaseMutation
    argument :order_id, ID, required: true

    type Common::Types::OrderType

    def resolve(**attributes)
      authenticated do
        current_vendor.orders.find(attributes[:order_id]).tap do |order|
          order.update!(fullcheck_consent: true)
          order.underwrite!(order.customer.primary_contact)
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
