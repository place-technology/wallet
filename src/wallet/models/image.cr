module Wallet
  module Models
    class Image
      include JSON::Serializable

      @[JSON::Field(key: "icon")]
      property icon : String

      @[JSON::Field(key: "logo")]
      property logo : String

      protected def after_initialize
        if @icon.starts_with?("iVBORw0KGgo")
          icon = File.tempfile(".png") do |file|
            Base64.decode(@icon, file)
          end

          @icon = icon.path
        end

        if @logo.starts_with?("iVBORw0KGgo")
          logo = File.tempfile(".png") do |file|
            Base64.decode(@logo, file)
          end

          @logo = logo.path
        end
      end
    end
  end
end
