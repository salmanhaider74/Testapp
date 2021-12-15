module VendorApp::Mutations
  class Contacts::UpdateContact < BaseMutation
    argument :id, ID, required: true
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false
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

    def resolve(id:, **attributes)
      authenticated do
        current_vendor.contacts.find(id).tap do |contact|
          contact.update!(attributes)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found')
    end
  end
end
