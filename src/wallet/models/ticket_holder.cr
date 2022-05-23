module Wallet
  module Models
    class TicketHolder
      include JSON::Serializable

      @[JSON::Field(key: "firstName")]
      property first_name : String

      @[JSON::Field(key: "lastName")]
      property last_name : String
    end
  end
end
