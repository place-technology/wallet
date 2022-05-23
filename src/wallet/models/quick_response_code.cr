module Wallet
  module Models
    class QuickResponseCode
      include JSON::Serializable

      @[JSON::Field(key: "value")]
      property value : String

      @[JSON::Field(key: "altText")]
      property alt_text : String
    end
  end
end
