require "grip"
require "piranha"
require "google"
require "awscr-s3"

require "./wallet"
require "./wallet_web"

require "./wallet/**"
require "./wallet_web/**"

class Application < Grip::Application
  def routes
    error 404, WalletWeb::Errors::NotFound

    scope "/api" do
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
