module Encryptable
  extend ActiveSupport::Concern

  class_methods do
    def encrypts(*attributes)
      options = attributes.last
      options = { mask: 0 } unless options.instance_of? Hash

      attributes.reject! { |v| v.instance_of? Hash }

      attributes.each do |attribute|
        define_method("#{attribute}=".to_sym) do |value|
          if respond_to?("encrypted_#{attribute}=")
            return unless value.exclude?('*')

            public_send("encrypted_#{attribute}=".to_sym, EncryptionService.encrypt(value))
          else
            super(value)
          end
        end

        define_method(attribute) do
          if respond_to?("encrypted_#{attribute}")
            value = public_send("encrypted_#{attribute}".to_sym)
            decrypted_attribute = EncryptionService.decrypt(value)
            return nil unless decrypted_attribute.present?

            decrypted_attribute.chars.last(options[:mask]).join.rjust(decrypted_attribute.length, '*')
          end
        end

        define_method("#{attribute}_unmasked") do
          if respond_to? "encrypted_#{attribute}"
            value = public_send("encrypted_#{attribute}".to_sym)
            EncryptionService.decrypt(value)
          else
            super()
          end
        end
      end
    end
  end
end
