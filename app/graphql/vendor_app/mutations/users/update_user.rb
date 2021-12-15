module VendorApp::Mutations
  class Users::UpdateUser < BaseMutation
    argument :id, ID, required: true
    argument :first_name, String, required: false
    argument :last_name, String, required: false
    argument :email, String, required: false
    argument :password, String, required: false
    argument :phone, String, required: false

    type Common::Types::SessionType

    def resolve(id:, **attributes)
      authenticated do
        current_vendor.users.find(id).tap do |user|
          user.update!(attributes)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.messages.to_json, extensions: { code: GraphqlHelper::ERRORS[:VALIDATION_ERROR] })
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end
  end
end
