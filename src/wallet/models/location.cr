module Wallet
  module Models
    class Location
      include JSON::Serializable

      @[JSON::Field(key: "latitude")]
      property latitude : Float64

      @[JSON::Field(key: "longitude")]
      property longitude : Float64

      @[JSON::Field(key: "name")]
      property name : String

      @[JSON::Field(key: "address")]
      property address : String
    end
  end
end
