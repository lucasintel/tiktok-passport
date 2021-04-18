module TiktokPassport
  class Server
    include Router

    HOST = "0.0.0.0"
    PORT = ENV.fetch("PORT", "3000").to_i

    Log = ::Log.for(self)

    @log_handler = HTTP::LogHandler.new(Log)
    @error_handler = HTTP::ErrorHandler.new
    @server : HTTP::Server

    def initialize(@pool : SessionPool)
      draw_routes
      handlers = [@log_handler, @error_handler, route_handler]

      @server = HTTP::Server.new(handlers)
    end

    def draw_routes
      post "/" do |ctx|
        ctx.response.content_type = "application/json"

        body = ctx.request.body
        if body.nil?
          ctx.response.status = HTTP::Status::UNPROCESSABLE_ENTITY
          ctx.response.print(
            {status: "error", message: "Missing target URL"}.to_json
          )
          next ctx
        end

        url = body.gets_to_end

        begin
          signature = @pool.sign(url)
          ctx.response.print({status: "ok", data: signature}.to_json)
        rescue ex : Session::ConnectionLost
          ctx.response.status = HTTP::Status::SERVICE_UNAVAILABLE
          ctx.response.print(
            {status: "error", message: "Couldn't reach remote browser"}.to_json
          )
        rescue ex
          ctx.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
          ctx.response.print(
            {status: "exception", trace: ex.inspect_with_backtrace}.to_json
          )
        end

        ctx
      end
    end

    def run
      signal = Channel(Nil).new

      {% for signal in %w[TERM INT] %}
        Signal::{{signal.id}}.trap do
          Log.info { "[SIG{{signal.id}}] Received graceful stop" }
          @server.close
          @pool.stop
          signal.send(nil)
        end
      {% end %}

      Log.info { "Listening on PORT #{PORT}" }
      @server.bind_tcp(HOST, PORT)
      @server.listen

      signal.receive

      Log.info { "Down" }
    end
  end
end
