class PayoutVendorsJob < ApplicationJob
  queue_as :scheduler

  def perform(*_args)
    Account.where("balance_cents > 0 and resource_type = 'Vendor'").each do |acc|
      payment_method = acc.resource.default_payment_method
      acc.resource.payout! if payment_method.present? && payment_method.ach?
    end
  end
end
