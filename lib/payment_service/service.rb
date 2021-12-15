module PaymentService
  class Service
    def initialize
      @service = Services::Dwolla.new
    end

    def collect_payment(payment_method, invoice_amount)
      raise 'no payment service found' if @service.nil?

      @service.collect_payment(payment_method, invoice_amount)
    end

    def payout(vendor, amount, payment_method)
      @service.payout(vendor, amount, payment_method)
    end

    def create_account(dw_account, receive_only)
      @service.create_account(dw_account, receive_only)
    end

    def create_funding_source(dw_account, payment_method)
      @service.create_funding_source(dw_account, payment_method)
    end

    def initiate_micro_deposits(payment_method)
      @service.initiate_micro_deposits(payment_method)
    end
  end
end
