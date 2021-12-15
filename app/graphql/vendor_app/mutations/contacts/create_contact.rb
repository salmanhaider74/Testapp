module VendorApp::Mutations
  class Contacts::CreateContact < BaseMutation
    argument :customer_id, ID, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :phone, String, required: false
    argument :role, String, required: false
    argument :ssn, String, required: false
    argument :dob, GraphQL::Types::ISO8601Date, required: false
    argument :street, String, required: false
    argument :suite, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :zip, String, required: false
    argument :country, String, required: false

    type Common::Types::ContactType

    def resolve(**attributes)
      authenticated do
        contact = nil
        current_vendor.customers.find(attributes[:customer_id]).tap do |customer|
          contact = Contact.create!(attributes.except(:customer_id).merge(customer: customer))
        end
        contact
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found')
    end
  end
end
