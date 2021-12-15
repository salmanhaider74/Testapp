module Common::Types
  class InvoicePaymentType < BaseObject
    field :id, ID, null: false
    field :payment, PaymentType, null: false
  end
end
