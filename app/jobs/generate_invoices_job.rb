class GenerateInvoicesJob < ApplicationJob
  queue_as :scheduler

  def perform(*_args)
    skip_ids = PaymentScheduleItem.joins(:invoice_item).where('due_date <= ?', Date.today).map(&:id)
    schd_items = PaymentScheduleItem.where('payment_schedule_items.due_date <= ?', Date.today).where.not(id: skip_ids)
    schd_items.group_by { |x| x.order.customer }.each do |customer, items|
      invoice = customer.invoices.create
      due_dates = []
      items.each do |schd_item|
        invoice.invoice_items.create!(get_invoice_items(schd_item))
        due_dates << schd_item.due_date
      end
      invoice.update!(amount: invoice.invoice_items.sum(&:amount), due_date: due_dates.max)
    end
  end

  private

  def get_invoice_items(schd_item)
    order = schd_item.order
    order.order_items.map do |order_item|
      {
        amount: schd_item.payment,
        name: order_item.name,
        description: order_item.description,
        payment_schedule_item: schd_item,
        order_item: order_item,
      }
    end
  end
end
