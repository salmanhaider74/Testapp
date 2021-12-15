module VendorApp::Mutations
  CUSTOMER_ATTRIBUTES = [:name, :entity_type].freeze
  CONTACT_ATTRIBUTES = [:first_name, :last_name, :email, :phone].freeze
  ORDER_ATTRIBUTES = [:end_date, :amount, :interest_rate_subsidy, :start_date].freeze

  class Orders::CreateOrder < BaseMutation
    argument :customer_id, ID, required: false
    argument :name, String, required: false
    argument :entity_type, String, required: false
    argument :street, String, required: false
    argument :suite, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :zip, String, required: false
    argument :country, String, required: false
    argument :duns_number, String, required: false
    argument :ein, String, required: false
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false
    argument :phone, String, required: false
    argument :end_date, GraphQL::Types::ISO8601Date, required: true
    argument :amount, Float, required: true
    argument :interest_rate_subsidy, Float, required: true
    argument :start_date, GraphQL::Types::ISO8601Date, required: true

    type Common::Types::OrderType

    def resolve(**attributes)
      authenticated do
        order = nil
        if attributes[:customer_id].present?
          Order.transaction do
            customer = current_vendor.customers.find(attributes[:customer_id])
            order = customer.orders.create!(attributes.slice(*ORDER_ATTRIBUTES))
          end
        else
          Order.transaction do
            customer = Customer.create!(attributes.except(*ADDRESS_ATTRIBUTES, *CONTACT_ATTRIBUTES, *ORDER_ATTRIBUTES).merge(vendor_id: current_vendor.id))
            customer.addresses.create!(attributes.slice(*ADDRESS_ATTRIBUTES))
            customer.contacts.create!(attributes.slice(*CONTACT_ATTRIBUTES))
            order = customer.orders.create!(attributes.slice(*ORDER_ATTRIBUTES).merge(user_id: current_user.id))
          end
        end
        order
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
