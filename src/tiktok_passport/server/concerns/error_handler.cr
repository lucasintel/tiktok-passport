module TiktokPassport
  class Server
    module ErrorHandler
      private def render_unprocessable_entity!
        @ctx.response.status = HTTP::Status::UNPROCESSABLE_ENTITY
        @ctx.response.print({status: "error", message: "Missing target URL"}.to_json)
        @ctx
      end

      private def render_service_unavailable!
        @ctx.response.status = HTTP::Status::SERVICE_UNAVAILABLE
        @ctx.response.print({status: "error", message: "Couldn't reach remote browser"}.to_json)
        @ctx
      end

      private def render_exception!(ex)
        @ctx.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
        @ctx.response.print({status: "exception", trace: ex.inspect_with_backtrace}.to_json)
        @ctx
      end
    end
  end
end
