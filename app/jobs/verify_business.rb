class VerifyBusiness < ApplicationJob
  queue_as :dnb

  def perform(customer_id)
    customer = Customer.find(customer_id)
    return if customer.nil? || customer.default_address.nil?

    dnb_client = Underwriting::Processors::Dnb::Client.new
    duns_number = dnb_client.get_duns_number(customer)
    customer.update!(verified_at: Time.now, duns_number: duns_number) unless duns_number.empty?
  end
end
