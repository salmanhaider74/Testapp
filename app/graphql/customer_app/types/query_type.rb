module CustomerApp::Types
  class QueryType < Common::Types::BaseObject
    field :session, Common::Types::SessionType, null: true

    def session
      authenticated do
        current_session
      end
    end

    private

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
