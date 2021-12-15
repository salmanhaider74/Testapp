module VendorApp::Mutations
  class Orders::UpdateOrder < BaseMutation
    argument :id, ID, required: true
    argument :term, Float, required: false
    argument :amount, Float, required: false
    argument :interest_rate, Float, required: false
    argument :interest_rate_subsidy, Float, required: false
    argument :start_date, GraphQL::Types::ISO8601Date, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: false

    type Common::Types::OrderType

    def resolve(id:, **attributes)
      authenticated do
        current_vendor.orders.find(id).tap do |order|
          order.update!(attributes)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
