class PullDnbReport < ApplicationJob
  queue_as :dnb

  def perform(order_id)
    order = Order.find(order_id)
    duns_number = order.customer.duns_number
    return unless duns_number.present?

    dnb_client = Underwriting::Processors::Dnb::Client.new

    dnb_json_report = dnb_client.get_json_report(duns_number)
    dnb_pdf_report = dnb_client.get_pdf_report(duns_number)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: dnb_pdf_report,
      filename: "DNB_#{duns_number}.pdf",
      content_type: 'application/pdf'
    )
    Document.create!(order_id: order.id, customer_id: order.customer.id, type: :duns, document: blob, json_data: dnb_json_report)

    order.underwrite!(order.customer.primary_contact)
  end
end
