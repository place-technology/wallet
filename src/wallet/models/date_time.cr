module Wallet
  module Models
    class DateTime
      include JSON::Serializable

      @[JSON::Field(key: "start")]
      property start : String

      @[JSON::Field(key: "end")]
      property end : String
    end
  end
end
