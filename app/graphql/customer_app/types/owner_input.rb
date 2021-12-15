class CustomerApp::Types::OwnerInput < Common::Types::BaseInputObject
  description 'Attributes for owner object'

  argument :id, ID, required: false
  argument :first_name, String, required: true
  argument :last_name, String, required: true
  argument :ownership, Float, required: false
  argument :phone, String, required: true
  argument :role, String, required: true
  argument :ssn, String, required: false
  argument :dob, GraphQL::Types::ISO8601Date, required: false
  argument :street, String, required: false
  argument :suite, String, required: false
  argument :city, String, required: false
  argument :state, String, required: false
  argument :zip, String, required: false
  argument :country, String, required: false
  argument :email, String, required: true
end
