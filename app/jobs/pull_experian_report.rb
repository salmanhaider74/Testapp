class PullExperianReport < ApplicationJob
  queue_as :experian

  def perform(order_id)
    order = Order.find(order_id)
    return unless order.present?

    experian_client = Underwriting::Processors::Experian::Client.new

    experian_bin = order.customer.bin
    experian_bin = experian_client.get_bin_number(order.customer) if experian_bin.nil?
    return if experian_bin.nil?

    order.customer.update!(bin: experian_bin)
    experian_json_report = experian_client.get_json_report(experian_bin)
    experian_pdf_report = experian_client.get_pdf_report(experian_bin)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: experian_pdf_report,
      filename: "Experian_#{experian_bin}.pdf",
      content_type: 'application/pdf'
    )
    Document.create!(order_id: order.id, customer_id: order.customer.id, type: :experian, document: blob, json_data: experian_json_report)
    order.underwrite!(order.customer.primary_contact)
  end
end
