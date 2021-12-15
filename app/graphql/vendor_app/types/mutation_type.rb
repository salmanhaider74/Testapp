module VendorApp::Types
  class MutationType < Common::Types::BaseObject
    field :update_password, mutation: VendorApp::Mutations::Users::UpdatePassword
    field :reset_password, mutation: VendorApp::Mutations::Users::ResetPassword
    field :update_user, mutation: VendorApp::Mutations::Users::UpdateUser
    field :create_user, mutation: VendorApp::Mutations::Users::CreateUser
    field :sign_out, mutation: VendorApp::Mutations::Sessions::DestroySession
    field :sign_in, mutation: VendorApp::Mutations::Sessions::CreateSession
    field :update_vendor, mutation: VendorApp::Mutations::Vendors::UpdateVendor
    field :create_customer, mutation: VendorApp::Mutations::Customers::CreateCustomer
    field :update_customer, mutation: VendorApp::Mutations::Customers::UpdateCustomer
    field :create_contact, mutation: VendorApp::Mutations::Contacts::CreateContact
    field :update_contact, mutation: VendorApp::Mutations::Contacts::UpdateContact
    field :destroy_contact, mutation: VendorApp::Mutations::Contacts::DestroyContact
    field :create_order, mutation: VendorApp::Mutations::Orders::CreateOrder
    field :update_order, mutation: VendorApp::Mutations::Orders::UpdateOrder
    field :upload_order_document, mutation: VendorApp::Mutations::Orders::UploadOrderDocument
    field :grant_fullcheck_consent, mutation: VendorApp::Mutations::Orders::GrantFullcheckConsent
    field :send_order_application, mutation: VendorApp::Mutations::Orders::SendOrderApplication
  end
end
