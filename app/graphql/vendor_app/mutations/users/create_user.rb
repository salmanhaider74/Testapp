module VendorApp::Mutations
  class Users::CreateUser < BaseMutation
    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :phone, String, required: false

    type Common::Types::SessionType

    def resolve(**attributes)
      authenticated do
        User.create!(attributes.merge(vendor: current_vendor))
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    end
  end
end
