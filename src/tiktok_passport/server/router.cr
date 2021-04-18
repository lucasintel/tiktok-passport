require "./controllers/*"

module TiktokPassport
  class Server
    class Router
      def call(ctx : HTTP::Server::Context)
        if ctx.request.method == "POST" && ctx.request.path == "/"
          SignaturesController.new(ctx).call
        end
      end
    end
  end
end
