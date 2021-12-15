class Agreement
  def self.generate_order_summary(order)
    controller = ActionController::Base.new
    html_rendered = controller.render_to_string template: 'layouts/order_summary.html.erb',
                                                locals: {
                                                  order: order,
                                                  contact: order.customer.primary_contact,
                                                  customer: order.customer,
                                                  vendor: order.customer.vendor,
                                                  start_date: order.start_date.strftime('%m/%d/%Y'),
                                                  end_date: order.end_date.strftime('%m/%d/%Y'),
                                                  order_items: order.order_items.blank? ? [] : order.order_items,
                                                  personal_guarantees: order.personal_guarantees.blank? ? [] : order.personal_guarantees,
                                                  default_payment_method: order.customer.default_payment_method,
                                                }

    content = WickedPdf.new.pdf_from_string(html_rendered)
    path = Rails.root.join('tmp', 'agreement.pdf')
    File.open(path, 'wb') { |file| file << content }
    path
  rescue StandardError => e
    "Error: #{e}"
  end
end
