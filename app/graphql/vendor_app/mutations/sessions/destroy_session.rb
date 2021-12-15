module VendorApp::Mutations
  class Sessions::DestroySession < BaseMutation
    type Common::Types::SessionType

    def resolve
      authenticated do
        current_session.destroy
      end
    end
  end
end
