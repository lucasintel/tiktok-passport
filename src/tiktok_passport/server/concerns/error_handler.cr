module TiktokPassport
  class Server
    module ErrorHandler
      private def render(status_code, message)
        @ctx.response.status_code = status_code
        @ctx.response.print({status: "error", message: message}.to_json)
        @ctx
      end

      private def render_exception(ex)
        @ctx.response.status = HTTP::Status::INTERNAL_SERVER_ERROR
        @ctx.response.print({status: "exception", trace: ex.inspect_with_backtrace}.to_json)
        @ctx
      end
    end
  end
end
