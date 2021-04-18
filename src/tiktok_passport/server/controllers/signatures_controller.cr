require "../concerns/error_handler"

module TiktokPassport
  class Server
    class SignaturesController
      include ErrorHandler

      def initialize(@ctx : HTTP::Server::Context)
        @ctx.response.content_type = "application/json"
      end

      def call
        body = @ctx.request.body
        return render_unprocessable_entity! if body.nil?

        url = body.gets_to_end

        begin
          signature = Signer.sign(url)
          @ctx.response.print({status: "ok", data: signature}.to_json)
        rescue ex : Signer::Session::ConnectionLost
          render_service_unavailable!
        rescue ex
          render_exception!(ex)
        end
      end
    end
  end
end
