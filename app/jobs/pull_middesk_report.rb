class PullMiddeskReport < ApplicationJob
  queue_as :middesk

  def perform(order_id)
    order = Order.find(order_id)
    middesk_id = order.customer.middesk_id
    return unless middesk_id.present?

    middesk_client = Underwriting::Processors::Middesk::Client.new

    middesk_json_report = middesk_client.get_json_report(middesk_id)
    middesk_pdf_report = middesk_client.get_pdf_report(middesk_id)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: middesk_pdf_report,
      filename: "Middesk_#{middesk_id}.pdf",
      content_type: 'application/pdf'
    )
    Document.create!(order_id: order.id, customer_id: order.customer.id, type: :middesk, document: blob, json_data: middesk_json_report)
  end
end
