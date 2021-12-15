module Common::Types
  class VendorType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :street, String, null: true
    field :suite, String, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :zip, String, null: true
    field :country, String, null: true
    field :domain, String, null: true
    field :logo_url, String, null: true
    field :favicon_url, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :users, [UserType], null: false
    field :customers, [CustomerType], null: false
    field :orders, [OrderType], null: false
    field :payments, [PaymentType], null: false
    field :account, AccountType, null: false
    field :product, ProductType, null: true
    field :transactions, [TransactionType], null: false
    field :orders_by_status, GraphQL::Types::JSON, null: true do
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
    end
    field :orders_amount_and_fees, GraphQL::Types::JSON, null: true do
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :group, String, required: false
    end
    field :orders_amount_and_fees_by_size, GraphQL::Types::JSON, null: true do
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
    end
    field :orders_stats_by_size, GraphQL::Types::JSON, null: true do
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
    end
    field :average_fees, GraphQL::Types::JSON, null: true
    field :orders_amount_by_size, GraphQL::Types::JSON, null: true
    field :average_fees_by_size, GraphQL::Types::JSON, null: true
    field :order_stats_by_size, GraphQL::Types::JSON, null: true

    def orders_by_status(start_date: Float::INFINITY, end_date: DateTime.now)
      vals = []
      ords = object.orders.where(created_at: start_date..end_date)
      vals << { "label": 'Submitted', "value": ords.count }
      vals << { "label": 'Complete', "value": ords.where(loan_decision: %w[approved declined]).count }
      vals << { "label": 'Approved', "value": ords.where(loan_decision: 'approved').count }
      vals << { "label": 'Financed', "value": ords.where(loan_decision: 'approved', status: 'financed').count }
      vals
    end

    def quarter_label(dd)
      quarter = ''
      case dd.month
      when 1
        quarter = 'Q1'
      when 4
        quarter = 'Q2'
      when 7
        quarter = 'Q3'
      when 10
        quarter = 'Q4'
      end
      "#{quarter} - #{dd.year}"
    end

    def orders_amount_and_fees(start_date: Float::INFINITY, end_date: DateTime.now, group: 'month')
      vals = []
      ords = object.orders.where(created_at: start_date..end_date).map { |ob| { "date": ob.created_at, "amount": ob.amount, "fee": ob.discount } }
      case group
      when 'month'
        ords = ords.group_by { |t| Date::MONTHNAMES[t[:date].month] }
      when 'year'
        ords = ords.group_by { |t| t[:date].year }
      when 'day'
        ords = ords.group_by { |t| t[:date].day }
      when 'quarter'
        ords = ords.group_by { |t| quarter_label(t[:date].beginning_of_quarter) }
      end
      ords.each do |key, val|
        vals << { "label": key, "amount": val.sum { |a| a[:amount] }, "fee": (val.sum { |a| a[:fee] } / (val.sum { |a| a[:amount] }.positive? ? val.sum { |a| a[:amount] } : 1)).round(2) }
      end
      vals
    end

    def orders_amount_and_fees_by_size(start_date: Float::INFINITY, end_date: DateTime.now)
      val = []
      Order::SIZE_RANGES.each do |r|
        orders = object.orders.where(created_at: start_date..end_date).amount_between(r[:min], r[:max])
        val << { "label": r[:label], "amount": orders.sum(:amount_cents), "fee": (orders.sum(&:discount) / (orders.sum(&:amount).positive? ? orders.sum(&:amount) : 1)).round(2) }
      end
      val
    end

    def orders_stats_by_size(start_date: Float::INFINITY, end_date: DateTime.now)
      val = []
      Order::SIZE_RANGES.each do |r|
        ords = []
        object.orders.where(created_at: start_date..end_date).amount_between(r[:min], r[:max]).group(:status).count.each do |a|
          ords << { "status": a[0], "count": a[1] }
        end
        val << ["label": r[:label], "orders": ords]
      end
      val
    end

    def average_fees
      object.transactions.group_by_month(:created_at, format: '%b %Y').sum(:fees_cents)
    end

    def orders_amount_by_size
      result = {}
      Order::SIZE_RANGES.each do |r|
        result[r[:label]] = object.orders.amount_between(r[:min], r[:max]).sum(:amount_cents)
      end
      result
    end

    def order_stats_by_size
      result = {}
      Order::SIZE_RANGES.each do |r|
        result[r[:label]] = object.orders.amount_between(r[:min], r[:max]).group(:status).count
      end
      result
    end

    def average_fees_by_size
      result = {}
      Order::SIZE_RANGES.each do |r|
        result[r[:label]] = object.transactions.fees_between(r[:min], r[:max]).average(:fees_cents)
      end
      result
    end
  end
end
