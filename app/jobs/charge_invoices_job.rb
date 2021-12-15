class ChargeInvoicesJob < ApplicationJob
  queue_as :scheduler

  def perform(*_args)
    invoices = Invoice.where(due_date: Date.today)
    invoices.each do |invoice|
      payment_method = invoice.customer.default_payment_method
      invoice.charge! if payment_method.ach?
    end
  end
end
