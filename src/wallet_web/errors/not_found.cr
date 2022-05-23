module WalletWeb
  module Errors
    class NotFound < Grip::Controllers::Exception
      def call(context : Context) : Context
        context
          .json(
            {
              "error" => context.exception.try(&.to_s),
            }
          )
      end
    end
  end
end
