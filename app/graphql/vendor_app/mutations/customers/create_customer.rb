module VendorApp::Mutations
  ADDRESS_ATTRIBUTES = [:street, :city, :state, :zip, :country].freeze

  class Customers::CreateCustomer < BaseMutation
    argument :name, String, required: true
    argument :street, String, required: true
    argument :suite, String, required: false
    argument :city, String, required: true
    argument :state, String, required: true
    argument :zip, String, required: true
    argument :country, String, required: true
    argument :duns_number, String, required: false
    argument :ein, String, required: false

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        Customer.create!(attributes.except(*ADDRESS_ATTRIBUTES).merge(vendor: current_vendor, addresses_attributes: [attributes.slice(*ADDRESS_ATTRIBUTES)]))
        current_session.reload
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    end
  end
end
