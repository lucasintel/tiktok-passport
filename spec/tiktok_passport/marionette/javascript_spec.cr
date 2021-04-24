require "../../spec_helper"

describe TiktokPassport::Marionette::Javascript do
  describe ".escape_javascript" do
    it "escapes javascript" do
      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(string))
        .should eq(
          %(string)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(This "thing" is really\n netos'))
        .should eq(
          %(This \\"thing\\" is really\\n netos\\')
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(backslash\\test))
        .should eq(
          %(backslash\\\\test)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(dont </close> tags))
        .should eq(
          %(dont <\\/close> tags)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(unicode \u2028 newline))
        .should eq(
          %(unicode &#x2028; newline)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(unicode \342\200\250 newline))
        .should eq(
          %(unicode &#x2028; newline)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(unicode \u2029 newline))
        .should eq(
          %(unicode &#x2029; newline)
        )

      TiktokPassport::Marionette::Javascript
        .escape_javascript(%(unicode \342\200\251 newline))
        .should eq(
          %(unicode &#x2029; newline)
        )
    end
  end

  describe ".sign" do
    it "returns the sign function" do
      result = TiktokPassport::Marionette::Javascript.sign("http://tiktok.com")
      result.should eq(
        <<-JS
          return byted_acrawler.sign({ url: "http://tiktok.com" });
        JS
      )
    end

    it "escapes javascript" do
      result = TiktokPassport::Marionette::Javascript.sign("http://tiktok.com\"<b>abc</b>")
      result.should eq(
        <<-JS
          return byted_acrawler.sign({ url: "http://tiktok.com\\"<b>abc<\\/b>" });
        JS
      )
    end
  end

  describe ".navigator_info" do
    it "returns the navigator_info function" do
      result = TiktokPassport::Marionette::Javascript.navigator_info
      result.should eq(
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
      )
    end
  end
end
