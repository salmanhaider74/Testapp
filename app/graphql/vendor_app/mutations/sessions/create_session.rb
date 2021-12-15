module VendorApp::Mutations
  class Sessions::CreateSession < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    type Common::Types::SessionType

    def resolve(email:, password:)
      user = User.find_by_email(email)
      # TODO: store client IP address
      Session.create!(resource: user) if user.present? && user.valid_password?(password)
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    end
  end
end
