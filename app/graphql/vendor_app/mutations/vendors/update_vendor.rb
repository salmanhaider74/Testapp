module VendorApp::Mutations
  class Vendors::UpdateVendor < BaseMutation
    argument :name, String, required: false
    argument :street, String, required: false
    argument :suite, String, required: false
    argument :city, String, required: false
    argument :state, String, required: false
    argument :zip, String, required: false
    argument :country, String, required: false

    type Common::Types::VendorType

    def resolve(**attributes)
      authenticated do
        current_vendor.update!(attributes)
        current_vendor
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    end
  end
end
