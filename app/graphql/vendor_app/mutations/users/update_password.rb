module VendorApp::Mutations
  class Users::UpdatePassword < BaseMutation
    argument :token, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true

    field :success, Boolean, null: false

    def resolve(token:, password:, password_confirmation:)
      user   = User.find_by_reset_password_token(token)
      result = user.present? ? user.reset_password(password, password_confirmation) : false
      { success: result }
    end
  end
end
