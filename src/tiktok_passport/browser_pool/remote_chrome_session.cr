require "./session"

module TiktokPassport
  module Browser
    class RemoteChromeSession < Browser::Session
      TARGET_URL = "https://www.tiktok.com"

      # Disguise as iPhone 12 Pro.
      CHROME_CAPABILITIES = [
        "--headless",
        "--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
        "--device_scale_factor=3",
        "--height=844",
        "--width=390",
      ]

      Log = ::Log.for(self)

      @driver : Selenium::Driver
      @session : Selenium::Session

      getter user_agent : String

      def initialize(remote_url : String)
        @driver = Selenium::Driver.for(:chrome, base_url: remote_url)
        @session = @driver.create_session(CHROME_CAPABILITIES)
        @user_agent = @session.document_manager.execute_script(Javascript.user_agent)

        Log.info(&.emit("Warming up", id: @session.id))
        navigate_to_target_url

        Log.info(&.emit("Ready", id: @session.id))
      end

      def sign(url) : String
        navigate_to_target_url
        @session.document_manager.execute_script(Javascript.sign(url))
      end

      def verify_fp
        navigate_to_target_url
        @session.document_manager.execute_script(Javascript.get_cookie("s_v_web_id"))
      end

      def recycle
        previous_id = @session.id

        Log.info(&.emit("Recycling", previous_id: previous_id))

        @session = @driver.create_session(CHROME_CAPABILITIES)
        navigate_to_target_url

        Log.info(&.emit("Recycled", previous_id: previous_id, id: @session.id))
      end

      private def navigate_to_target_url
        @session.navigate_to(TARGET_URL) unless warmed_up?
      end

      private def warmed_up?
        @session.current_url.includes?("tiktok")
      end
    end
  end
end
