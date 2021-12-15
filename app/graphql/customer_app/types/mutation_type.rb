module CustomerApp::Types
  class MutationType < Common::Types::BaseObject
    field :update_business_details, mutation: CustomerApp::Mutations::Checkout::UpdateBusinessDetails
    field :update_personal_details, mutation: CustomerApp::Mutations::Checkout::UpdatePersonalDetails
    field :create_owners, mutation: CustomerApp::Mutations::Checkout::CreateOwners
    field :update_personal_guarantee, mutation: CustomerApp::Mutations::Checkout::UpdatePersonalGuarantee
    field :send_application, mutation: CustomerApp::Mutations::Checkout::SendApplication
    field :underwrite_owner, mutation: CustomerApp::Mutations::Checkout::UnderwriteOwner
    field :upload_financial_documents, mutation: CustomerApp::Mutations::Checkout::UploadFinancialDocuments
    field :destroy_owner, mutation: CustomerApp::Mutations::Checkout::DestroyOwner
    field :upsert_payment_method, mutation: CustomerApp::Mutations::Checkout::UpsertPaymentMethod
    field :save_signed_agreement, mutation: CustomerApp::Mutations::Checkout::SaveSignedAgreement
    field :update_contact_verification_status, mutation: CustomerApp::Mutations::Checkout::UpdateContactVerificationStatus
  end
end
