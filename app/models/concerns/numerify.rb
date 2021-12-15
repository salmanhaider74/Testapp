module Numerify
  LENGTH = 8

  extend ActiveSupport::Concern

  included do
    validates :number, presence: true
    validates :number, frozen: true, if: :id?
    before_validation :set_number, on: :create
  end

  private

  def set_number
    loop do
      pfx = self.class.name.first
      hex = SecureRandom.hex(3).upcase.rjust(LENGTH, '0')
      self.number = "#{pfx}-#{hex}"

      break if self.class.where(number: number).empty?
    end
  end
end
