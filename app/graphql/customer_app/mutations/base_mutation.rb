module CustomerApp::Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false
    # argument_class Types::BaseArgument
    # field_class Types::BaseField
    # input_object_class Types::BaseInputObject
    # object_class Types::BaseObject

    def authenticated
      if current_session.present?
        yield
      else
        GraphQL::ExecutionError.new('Invalid session', extensions: { code: GraphqlHelper::ERRORS[:AUTHENTICATION_ERROR] })
      end
    end

    def current_contact
      context[:current_contact]
    end

    def current_session
      context[:current_session]
    end

    def current_customer
      context[:current_customer]
    end

    def current_order
      context[:current_order]
    end
  end
end
