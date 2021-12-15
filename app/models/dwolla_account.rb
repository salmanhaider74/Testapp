# == Schema Information
#
# Table name: dwolla_accounts
#
#  id             :bigint           not null, primary key
#  resource_type  :string           not null
#  resource_id    :bigint           not null
#  is_master      :string
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  verified       :boolean          default(FALSE), not null
#  funding_source :string
#
class DwollaAccount < ApplicationRecord
  belongs_to :resource, polymorphic: true

  def self.create_account(resource, recieve_only)
    dw_account = DwollaAccount.create!(resource: resource)
    payment_service = PaymentService::Service.new
    payment_service.create_account(dw_account, recieve_only)
  end
end
