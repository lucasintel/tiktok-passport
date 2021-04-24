module TiktokPassport
  module Signer
    module Javascript
      JAVASCRIPT_ESCAPE_REGEX = /(\\|<\/|\r\n|\x{2028}|\x{2029}|[\n\r"']|[`]|[$])/
      JAVASCRIPT_ESCAPE_MAP   = {
        "\\"           => "\\\\",
        "</"           => "<\\/",
        "\r\n"         => "\\n",
        "\n"           => "\\n",
        "\r"           => "\\n",
        "\""           => "\\\"",
        "'"            => "\\'",
        "`"            => "\\`",
        "$"            => "\\$",
        "\342\200\250" => "&#x2028;",
        "\342\200\251" => "&#x2029;",
      }

      def self.escape_javascript(script : String)
        return "" if script.blank?

        script.gsub(JAVASCRIPT_ESCAPE_REGEX, JAVASCRIPT_ESCAPE_MAP)
      end

      def self.sign(url : String) : String
        <<-JS
          return byted_acrawler.sign({ url: "#{escape_javascript(url)}" });
        JS
      end

      def self.navigator_info : String
        <<-JS
          return {
            user_agent: navigator.userAgent,
            screen_width: screen.width,
            screen_height: screen.height,
            browser_language: navigator.language,
            browser_platform: navigator.platform,
            browser_name: navigator.appCodeName,
            browser_version: navigator.appVersion,
          }
        JS
      end
    end
  end
end
