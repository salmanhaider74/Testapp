module VendorApp::Mutations
  class Contacts::DestroyContact < BaseMutation
    argument :id, ID, required: true

    type Common::Types::ContactType

    def resolve(id:)
      authenticated do
        current_vendor.contacts.find(id).tap(&:destroy!)
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found')
    end
  end
end
