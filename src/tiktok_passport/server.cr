module TiktokPassport
  class Server
    include Router

    HOST = "0.0.0.0"
    PORT = ENV.fetch("PORT", "3000").to_i

    Log = ::Log.for(self)

    @log_handler = HTTP::LogHandler.new(Log)
    @error_handler = HTTP::ErrorHandler.new

    def initialize(@browser_pool : TiktokPassport::BrowserPool)
    end

    def draw_routes
      post "/" do |ctx|
        ctx.response.content_type = "application/json"

        body = ctx.request.body
        if body.nil?
          ctx.response.status = HTTP::Status::UNPROCESSABLE_ENTITY
          ctx.response.print(
            {status: "error", status_detail: "missing request url"}
          )
          next ctx
        end

        url = body.gets_to_end

        begin
          signature = @browser_pool.sign(url)
          ctx.response.print({status: "ok", data: signature}.to_json)
        rescue ex
          ctx.response.print(
            {status: "exception", trace: ex.inspect_with_backtrace}.to_json
          )
        end

        ctx
      end
    end

    def run
      draw_routes

      handlers = [@log_handler, @error_handler, route_handler]

      server = HTTP::Server.new(handlers)
      server.bind_tcp(HOST, PORT)

      Log.info { "Listening on PORT #{PORT}" }
      server.listen
    end
  end
end
