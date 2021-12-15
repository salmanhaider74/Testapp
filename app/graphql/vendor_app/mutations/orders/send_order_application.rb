module VendorApp::Mutations
  class Orders::SendOrderApplication < BaseMutation
    argument :order_id, ID, required: true

    type Common::Types::OrderType

    def resolve(**attributes)
      authenticated do
        current_vendor.orders.find(attributes[:order_id]).tap(&:send_application!)
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
