module Wallet
  class Constants
    APPLE_SIGNING_CERTIFICATE  = self.base64("APPLE_SIGNING_CERTIFICATE")
    APPLE_WWDR_CERTIFICATE     = self.base64("APPLE_WWDR_CERTIFICATE")
    APPLE_PRIVATE_KEY          = self.base64("APPLE_PRIVATE_KEY")
    APPLE_PRIVATE_KEY_PASSWORD = ENV["APPLE_PRIVATE_KEY_PASSWORD"]

    GOOGLE_PRIVATE_KEY        = self.base64("GOOGLE_PRIVATE_KEY")
    GOOGLE_CLIENT_EMAIL       = ENV["GOOGLE_CLIENT_EMAIL"]
    GOOGLE_WALLET_ISSUER_ID   = ENV["GOOGLE_WALLET_ISSUER_ID"]
    GOOGLE_WALLET_ISSUER_NAME = ENV["GOOGLE_WALLET_ISSUER_NAME"]

    AWS_REGION = ENV["AWS_REGION"]
    AWS_KEY    = ENV["AWS_KEY"]
    AWS_SECRET = ENV["AWS_SECRET"]
    AWS_BUCKET = ENV["AWS_BUCKET"]

    SECRET = ENV["SECRET"]

    protected def self.base64(key : String) : String
      raise ArgumentError.new("Base64-encoded ENV #{key} is empty") unless ENV[key]?.presence
      value = String.new(Base64.decode(ENV[key]))

      value
    end
  end
end
