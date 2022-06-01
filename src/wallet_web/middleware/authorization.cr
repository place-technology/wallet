module WalletWeb
  module Middleware
    class Authorization
      include HTTP::Handler

      def call(context : HTTP::Server::Context) : HTTP::Server::Context
        host = context.get_req_header("Host")
        api_key = context.get_req_header("X-API-Key")

        unless OpenSSL::HMAC.hexdigest(:sha512, Wallet::Constants::SECRET, host) == api_key
          raise Exception.new("This endpoint requires an `X-API-Key` header, you either did not supply it or supplied the incorrect one.")
        end

        context
      rescue exception
        context
          .put_status(401)
          .json({"error" => exception.message})
          .halt
      end
    end
  end
end
