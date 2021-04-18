require "./server/*"

module TiktokPassport
  class Server
    HOST = "0.0.0.0"
    PORT = ENV.fetch("PORT", "3000").to_i

    Log = ::Log.for(self)

    @server : HTTP::Server

    def initialize
      handlers = [
        HTTP::LogHandler.new(Log),
        HTTP::ErrorHandler.new,
      ]

      @router = Server::Router.new
      @server = HTTP::Server.new(handlers) do |ctx|
        @router.call(ctx)
      end
    end

    def start
      Log.info { "Listening on PORT #{PORT}" }
      @server.bind_tcp(HOST, PORT)
      @server.listen
    end

    def shutdown
      Log.info { "Shutting down server" }
      @server.close
    end
  end
end
