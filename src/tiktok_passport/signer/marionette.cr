require "../ext/selenium"
require "./marionette/*"

module TiktokPassport
  module Signer
    class Marionette
      {% begin %}
        # An array of javascript functions to be evaluated on page load.
        SCRIPTS_TO_EVALUATE_ON_NEW_DOCUMENT =
          String.build do |str|
            \{% for key, _index \
              in [
                   "#{__DIR__}/javascript/evasions/utils.js",
                   "#{__DIR__}/javascript/evasions/chrome.app.js",
                   "#{__DIR__}/javascript/evasions/chrome.csi.js",
                   "#{__DIR__}/javascript/evasions/chrome.loadTimes.js",
                   "#{__DIR__}/javascript/evasions/chrome.runtime.js",
                   "#{__DIR__}/javascript/evasions/iframe.contentWindow.js",
                   "#{__DIR__}/javascript/evasions/media.codecs.js",
                   "#{__DIR__}/javascript/evasions/navigator.hardwareConcurrency.js",
                   "#{__DIR__}/javascript/evasions/navigator.languages.js",
                   "#{__DIR__}/javascript/evasions/navigator.permissions.js",
                   "#{__DIR__}/javascript/evasions/navigator.plugins.js",
                   "#{__DIR__}/javascript/evasions/navigator.vendor.js",
                   "#{__DIR__}/javascript/evasions/navigator.webdriver.js",
                   "#{__DIR__}/javascript/evasions/webgl.vendor.js",
                   "#{__DIR__}/javascript/evasions/window.outerdimensions.js",
                   "#{__DIR__}/javascript/signer.js",
                 ] %}

              \{% if env("MINIFY_JS") && !key.includes?("signer.js") %}
                str << \{{ `uglifyjs --validate #{key}`.stringify }}
              \{% else %}
                str << \{{ read_file(key) }}
              \{% end %}
            \{% end %}
          end
      {% end %}

      # The remote browser desired capabilities.
      CHROME_CAPABILITIES =
        Selenium::Chrome::Capabilities.new.tap do |conf|
          conf.chrome_options.args = [
            "--headless",
            "--disable-blink-features=AutomationControlled",
            "--disable-infobars",
            "--window-size=1920,1080",
            "--start-maximized",
          ]

          conf.chrome_options.exclude_switches = [
            "enable-automation",
          ]
        end

      @driver : Selenium::Driver
      @session : Selenium::Session

      def initialize(remote_url : String)
        @driver = Selenium::Driver.for(:chrome, base_url: remote_url)
        @session = @driver.create_session(CHROME_CAPABILITIES)
        evade_user_agent_detection
        evade_viewport_detection
        register_functions
      end

      # Returns the current selenium session id.
      def id : String
        @session.id
      end

      # Navigates to the given *URL*.
      def navigate_to(url)
        @session.navigate_to(url)
      end

      # Takes a screenshot of the current page.
      def screenshot(path)
        @session.screenshot(path)
      end

      # Returns the navigator user agent.
      def user_agent : String
        payload = evaluate_cdp("Browser.getVersion")
        payload["userAgent"].as_s
      end

      # Overrides the navigator user agent.
      def user_agent=(desired_user_agent)
        evaluate_cdp(
          "Network.setUserAgentOverride", desired_user_agent
        )
      end

      # Evaluates a *script* and wait for the response.
      def evaluate(script, args = [] of String)
        @session.document_manager.execute_script(script, args)
      end

      # Evaluates a CDP (Selenium Chrome DevTools Protocol) *command*.
      def evaluate_cdp(command, params = {} of String => String)
        @session.document_manager.execute_cdp(command, params)
      end

      # Terminates the current selenium session.
      def stop
        @session.delete
      end

      # Stealth.
      private def evade_user_agent_detection
        new_user_agent =
          user_agent
            .gsub("HeadlessChrome", "Chrome")
            .gsub(/\(([^)]+)\)/, "(Windows NT 10.0; Win64; x64)")

        parser = UserAgentParser.new(new_user_agent)

        self.user_agent = {
          userAgent:         new_user_agent,
          platform:          "Win32",
          userAgentMetadata: {
            brands:          parser.brands,
            fullVersion:     parser.full_version,
            platform:        parser.platform,
            platformVersion: parser.platform_version,
            architecture:    parser.architecture,
            model:           parser.model,
            mobile:          parser.mobile,
          },
        }
      end

      # Stealth.
      private def evade_viewport_detection
        width = Random.rand(1700..1900).to_i64
        height = Random.rand(700..995).to_i64

        @session.window_manager.resize_window(width, height)
      end

      # Stealth.
      private def register_functions
        evaluate_cdp(
          "Page.addScriptToEvaluateOnNewDocument",
          {source: SCRIPTS_TO_EVALUATE_ON_NEW_DOCUMENT}
        )
      end
    end
  end
end
