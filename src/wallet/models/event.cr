require "./ticket_holder"
require "./location"

module Wallet
  module Models
    class Event
      include JSON::Serializable

      @[JSON::Field(key: "name")]
      property name : String

      @[JSON::Field(key: "image")]
      property image : Image

      @[JSON::Field(key: "ticketHolder")]
      property ticket_holder : TicketHolder

      @[JSON::Field(key: "location")]
      property location : Location

      @[JSON::Field(key: "dateTime")]
      property date_time : DateTime

      @[JSON::Field(key: "quickResponseCode")]
      property quick_response_code : QuickResponseCode
    end
  end
end
