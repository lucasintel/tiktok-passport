module TiktokPassport
  class Server
    class PingController
      def initialize(@ctx : HTTP::Server::Context)
        @ctx.response.content_type = "application/json"
      end

      def call
        @ctx.response.print({status: "ok"}.to_json)
      end
    end
  end
end
