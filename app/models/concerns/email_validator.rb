require 'resolv'

class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    if value !~ EMAIL_REGEX
      record.errors.add(attribute, 'is invalid')
      return
    end

    record.errors.add(attribute, 'is not deliverable') unless mail_domain?(value)
  end

  private

  def mail_domain?(value)
    return true if Rails.env.test? || Rails.env.development? || Rails.env.ci?

    Resolv::DNS.open do |dns|
      dns.getresources(
        value.split('@', 2).last,
        Resolv::DNS::Resource::IN::MX
      ).any?
    end
  end
end
