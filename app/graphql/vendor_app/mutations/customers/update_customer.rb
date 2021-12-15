module VendorApp::Mutations
  class Customers::UpdateCustomer < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :street, String, required: false
    argument :suite, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :zip, String, required: false
    argument :country, String, required: false
    argument :duns_number, String, required: false
    argument :ein, String, required: false

    type Common::Types::SessionType

    def resolve(id:, **attributes)
      authenticated do
        current_vendor.customers.find(id).tap do |customer|
          customer.update!(attributes)
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
