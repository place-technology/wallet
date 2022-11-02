module WalletWeb
  module Controllers
    class PasscardController < Grip::Controllers::Http
      def post(context : Context) : Context
        serial_number = UUID.random.to_s
        event = Wallet::Models::Event.from_json(context.fetch_json_params.to_json)

        icon = File.tempfile(serial_number)
        logo = File.tempfile(serial_number)

        icon.write(Base64.decode(event.image.icon.split(",").last))
        logo.write(Base64.decode(event.image.logo.split(",").last))

        apple_pass_url = apple_pass(event, serial_number, icon, logo)
        google_pass_url = google_pass(event, serial_number, logo)

        context
          .put_status(201)
          .json({"applePassUrl" => apple_pass_url, "googlePassUrl" => google_pass_url})
      end

      private def apple_pass(event : Wallet::Models::Event, serial_number : String, icon : File, logo : File) : String
        metadata = JSON::PullParser.new(%(
          {
            "formatVersion" : 1,
            "passTypeIdentifier" : "pass.com.placeos.piranha",
            "teamIdentifier" : "J8ZV85V568",
            "serialNumber" : "#{serial_number}",
            "organizationName" : "ACA Projects Australia Pty Ltd",
            "description" : "PlaceOS Wallet Testing",
            "foregroundColor" : "rgb(255, 255, 255)",
            "backgroundColor" : "rgb(21, 24, 55)",
            "labelColor": "rgb(255, 255, 255)",
            "sharingProhibited": true,
            "voided": false,
            "locations": [],
            "generic": {}
          })
        )

        passbook = Piranha::Models::Passbook.new(metadata)

        date_time = Time::Format::ISO_8601_DATE_TIME.parse(event.date_time.start)

        passbook
          .generic
          .add_primary_field({"key" => "buildingName", "label" => "Building", "value" => event.location.name})
          .add_secondary_field({"key" => "date", "label" => "Date", "value" => [date_time.day.to_s, month(date_time.month), date_time.year.to_s].join(" ")})
          .add_secondary_field({"key" => "time", "label" => "Time", "value" => [date_time.hour.to_s, ":", date_time.minute.to_s].join})

        location = Piranha::Models::Location.new(JSON::PullParser.new(%({"latitude": #{event.location.latitude}, "longitude": #{event.location.longitude}})))
        passbook.locations.try(&.push(location))

        passbook.add_barcode(
          {
            "format"  => Piranha::Constants::BarcodeFormat::QR,
            "altText" => event.quick_response_code.alt_text,
            "message" => event.quick_response_code.value,
          }
        )

        manifest = Piranha::Manifest.new(passbook)

        manifest.add_file("icon.png", icon.rewind.gets_to_end)
        manifest.add_file("logo.png", logo.rewind.gets_to_end)

        stream = Piranha::Stream.new(passbook, manifest)

        io = stream.render(
          Wallet::Constants::APPLE_WWDR_CERTIFICATE,
          Wallet::Constants::APPLE_SIGNING_CERTIFICATE,
          Wallet::Constants::APPLE_PRIVATE_KEY,
          Wallet::Constants::APPLE_PRIVATE_KEY_PASSWORD
        )

        client = Awscr::S3::Client.new(Wallet::Constants::AWS_REGION, Wallet::Constants::AWS_KEY, Wallet::Constants::AWS_SECRET)
        uploader = Awscr::S3::FileUploader.new(client)

        uploader.upload(Wallet::Constants::AWS_BUCKET, [serial_number, "pkpass"].join("."), io.rewind)
        options = Awscr::S3::Presigned::Url::Options.new(
          aws_access_key: Wallet::Constants::AWS_KEY,
          aws_secret_key: Wallet::Constants::AWS_SECRET,
          region: Wallet::Constants::AWS_REGION,
          object: "/" + [serial_number, "pkpass"].join("."),
          bucket: Wallet::Constants::AWS_BUCKET,
          additional_options: {
            "Content-Type" => "application/vnd.apple.pkpass",
          }
        )

        url = Awscr::S3::Presigned::Url.new(options)
        url.for(:get)
      end

      private def google_pass(event : Wallet::Models::Event, serial_number : String, logo : File) : String
        auth = Google::Auth.new(
          issuer: Wallet::Constants::GOOGLE_CLIENT_EMAIL,
          signing_key: Wallet::Constants::GOOGLE_PRIVATE_KEY,
          scopes: "https://www.googleapis.com/auth/wallet_object.issuer",
          sub: "",
          user_agent: Google::Auth::DEFAULT_USER_AGENT
        )

        client = Awscr::S3::Client.new(Wallet::Constants::AWS_REGION, Wallet::Constants::AWS_KEY, Wallet::Constants::AWS_SECRET)
        uploader = Awscr::S3::FileUploader.new(client)

        uploader.upload(Wallet::Constants::AWS_BUCKET, [serial_number, "png"].join("."), logo.rewind)

        options = Awscr::S3::Presigned::Url::Options.new(
          aws_access_key: Wallet::Constants::AWS_KEY,
          aws_secret_key: Wallet::Constants::AWS_SECRET,
          region: Wallet::Constants::AWS_REGION,
          object: "/" + [serial_number, "png"].join("."),
          bucket: Wallet::Constants::AWS_BUCKET,
          additional_options: {
            "Content-Type" => "image/png",
          }
        )

        image_url = Awscr::S3::Presigned::Url.new(options).for(:get)

        event_ticket = Google::EventTickets.new(auth: auth,
          serial_number: serial_number,
          issuer_id: Wallet::Constants::GOOGLE_WALLET_ISSUER_ID,
          issuer_name: Wallet::Constants::GOOGLE_WALLET_ISSUER_NAME,
          event_name: event.name,
          ticket_holder_name: [event.ticket_holder.first_name, event.ticket_holder.last_name].join(" "),
          qr_code_value: event.quick_response_code.value,
          qr_code_alternate_text: event.quick_response_code.alt_text,
          location: {lat: event.location.latitude, lon: event.location.longitude},
          date_time: {start: event.date_time.start, end: event.date_time.end},
          venue: {name: event.location.name, address: event.location.address},
          logo_image: {uri: image_url, description: ""}
        )

        event_ticket.execute
      end

      private def month(value : Int32) : String
        months = {
           1 => "January",
           2 => "February",
           3 => "March",
           4 => "April",
           5 => "May",
           6 => "June",
           7 => "July",
           8 => "August",
           9 => "September",
          10 => "October",
          11 => "November",
          12 => "December",
        }

        months[value]? || value.to_s
      end
    end
  end
end
