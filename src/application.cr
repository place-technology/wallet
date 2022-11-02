require "grip"
require "piranha"
require "google"
require "awscr-s3"

require "./wallet"
require "./wallet_web"

require "./wallet/**"
require "./wallet_web/**"

class Application < Grip::Application
  def initialize
    super(environment: "production", serve_static: false)

    exception Grip::Exceptions::NotFound, WalletWeb::Exceptions::NotFound

    pipeline :api, [
      WalletWeb::Middleware::Authorization.new,
    ]

    scope "/api" do
      pipe_through :api

      post "/passcard", WalletWeb::Controllers::PasscardController
    end
  end

  def host
    ENV["HOST"]
  end

  def port
    ENV["PORT"].to_i
  end
end

app = Application.new
app.run
