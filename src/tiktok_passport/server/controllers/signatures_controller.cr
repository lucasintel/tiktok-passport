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
        return render(422, "Request body cannot be empty") if body.nil?

        begin
          parsed_body = JSON.parse(body.gets_to_end)

          url = parsed_body["url"].as_s?
          return render(422, "URL cannot be blank") if url.nil?

          signature = Signer.sign(url)
          @ctx.response.print({status: "ok", data: signature}.to_json)
        rescue ex : Marionette::ConnectionLost
          render(503, "Couldn't reach remote browser")
        rescue ex : JSON::ParseException
          render(422, "JSON::ParseException: #{ex.message}")
        rescue ex
          render_exception(ex)
        end
      end
    end
  end
end
