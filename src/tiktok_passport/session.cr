require "./session/*"

module TiktokPassport
  class Session
    TARGET_URL = "https://www.tiktok.com"
    VERIFY_FP  = "s_v_web_id"

    CHROME_CAPABILITIES = [
      "--headless",
      "--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
      "--device_scale_factor=3",
      "--height=844",
      "--width=390",
    ]

    Log = ::Log.for(self)

    @driver : Selenium::Driver
    @session : Selenium::Session?

    def initialize(remote_url : String)
      @driver = Selenium::Driver.for(:chrome, base_url: remote_url)
      @started = false
    end

    def start
      return if started?

      protect_from_connection_error do
        @started = true
        @session = @driver.create_session(CHROME_CAPABILITIES)

        Log.info(&.emit("Warming up", id: @session.not_nil!.id))
        navigate_to_target_url

        Log.info(&.emit("Ready", id: @session.not_nil!.id))
      end
    end

    def stop
      @started = false

      begin
        @session.not_nil!.delete
      rescue ex
      end
    end

    def sign(url) : String
      protect_from_connection_error do
        @session.not_nil!.document_manager.execute_script(
          Javascript.sign(url)
        )
      end
    end

    def user_agent : String
      protect_from_connection_error do
        @session.not_nil!.document_manager.execute_script(
          Javascript.user_agent
        )
      end
    end

    def verify_fp : String
      protect_from_connection_error do
        @session.not_nil!.document_manager.execute_script(
          Javascript.get_cookie(VERIFY_FP)
        )
      end
    end

    private def navigate_to_target_url
      protect_from_connection_error do
        @session.not_nil!.navigate_to(TARGET_URL)
      end
    end

    def recycle
      stop
    end

    def started?
      @started
    end

    def stopped?
      !started?
    end

    def protect_from_connection_error
      yield
    rescue ex : Socket::Error | Socket::ConnectError | IO::Error | Selenium::Error
      raise ConnectionLost.new
    end
  end
end
