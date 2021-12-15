module Phonify
  extend ActiveSupport::Concern

  included do
    validates :phone, phone: true, allow_blank: true
    before_save :normalize_phone
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end
end
