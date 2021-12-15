module VendorApp::Types
  class QueryType < Common::Types::BaseObject
    field :users, [Common::Types::UserType], null: false
    field :vendor, Common::Types::VendorType, null: true
    field :session, Common::Types::SessionType, null: true
    field :customers, [Common::Types::CustomerType], null: false
    field :orders, [Common::Types::OrderType], null: false
    field :invoices, [Common::Types::InvoiceType], null: false
    field :credit_transactions, [Common::Types::TransactionType], null: false
    field :debit_transactions, [Common::Types::TransactionType], null: false

    field :order, Common::Types::OrderType, null: true do
      description 'Find an order by Order Number'
      argument :number, String, required: true
    end

    field :customer, Common::Types::CustomerType, null: true do
      description 'Find a customer by Customer Number'
      argument :number, String, required: true
    end

    def vendor
      authenticated do
        current_vendor
      end
    end

    def users
      authenticated do
        current_vendor.users
      end
    end

    def session
      authenticated do
        current_session
      end
    end

    def customers
      authenticated do
        current_vendor.customers
      end
    end

    def orders
      authenticated do
        current_vendor.orders
      end
    end

    def debit_transactions
      authenticated do
        current_vendor.transactions.debit
      end
    end

    def credit_transactions
      authenticated do
        current_vendor.transactions.credit
      end
    end

    def order(number:)
      authenticated do
        current_vendor.orders.where(number: number).first
      end
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end

    def customer(number:)
      authenticated do
        current_vendor.customers.where(number: number).first
      end
    rescue ActiveRecord::RecordNotFound
      GraphQL::ExecutionError.new('Record not found', extensions: { code: GraphqlHelper::ERRORS[:NOT_FOUND] })
    end

    private

    def authenticated
      if current_session.present?
        yield
      else
        GraphQL::ExecutionError.new('Invalid session', extensions: { code: GraphqlHelper::ERRORS[:AUTHENTICATION_ERROR] })
      end
    end

    def current_user
      context[:current_user]
    end

    def current_session
      context[:current_session]
    end

    def current_vendor
      context[:current_vendor]
    end
  end
end
