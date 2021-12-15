require 'aws-sdk-kms'

class EncryptionService
  class << self
    def encrypt(plaintext)
      return nil unless plaintext.present?

      response = client.encrypt({
        key_id: key_id,
        plaintext: plaintext,
      })
      response.ciphertext_blob.unpack('H*').join
    end

    def decrypt(binary_string)
      return nil unless binary_string.present?

      begin
        response = client.decrypt({
          key_id: key_id,
          ciphertext_blob: binary_string.split.pack('H*'),
        })
        response.plaintext
      rescue Aws::KMS::Errors::InvalidCiphertextException
        binary_string
      end
    end

    private

    def key_id
      Rails.application.credentials[:aws][:kms][:cms_key_id]
    end

    def client
      options = {
        region: 'us-east-1',
        credentials: Aws::Credentials.new(
          Rails.application.credentials[:aws][:access_key_id],
          Rails.application.credentials[:aws][:secret_access_key]
        ),
      }
      Aws::KMS::Client.new(options.symbolize_keys)
    end
  end
end
