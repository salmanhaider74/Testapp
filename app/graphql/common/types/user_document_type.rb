module Common::Types
  class UserDocumentType < BaseObject
    field :id, ID, null: false
    field :type, String, null: false
    field :url, String, null: false
  end
end
