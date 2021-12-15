module Common::Types
  class ContactType < BaseObject
    field :id, ID, null: false
    field :primary, Boolean, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :full_name, String, null: true
    field :email, String, null: true
    field :phone, String, null: true
    field :ownership, Float, null: true
    field :role, String, null: true
    field :ssn, String, null: true
    field :dob, GraphQL::Types::ISO8601Date, null: true
    # field :street, String, null: true
    # field :suite, String, null: true
    # field :city, String, null: true
    # field :state, String, null: true
    # field :zip, String, null: true
    field :country, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :customer, CustomerType, null: false
    field :personal_guarantee, PersonalGuaranteeType, null: true
    field :is_owner, Boolean, null: false
    field :inquiry_id, String, null: true
    field :verified_at, GraphQL::Types::ISO8601DateTime, null: true
    field :verified, Boolean, null: false

    def verified
      object.inquiry_completed?
    end

    def is_owner # rubocop:disable Naming/PredicateName
      object.owner_role?
    end
  end
end
