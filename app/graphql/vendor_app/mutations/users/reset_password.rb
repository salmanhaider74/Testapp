module VendorApp::Mutations
  class Users::ResetPassword < BaseMutation
    argument :email, String, required: true

    field :success, Boolean, null: false

    def resolve(email:)
      user = User.find_by_email(email)
      user.try(:send_reset_password_instructions)
      { success: true }
    end
  end
end
