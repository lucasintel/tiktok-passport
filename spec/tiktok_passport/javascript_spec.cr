require "../spec_helper"

describe TiktokPassport::Javascript do
  describe ".get_cookie" do
    it "returns the getCookie function" do
      result = TiktokPassport::Javascript.get_cookie("s_v_web_id")
      result.should eq(
        <<-JS
          return (function (cookieName) {
            var cookieString = RegExp(cookieName+"=[^;]+").exec(document.cookie);
            return decodeURIComponent(!!cookieString ? cookieString.toString().replace(/^[^=]+./, "") : "");
          })("s_v_web_id");
        JS
      )
    end
  end

  describe ".sign" do
    it "returns the sign function" do
      result = TiktokPassport::Javascript.sign("http://tiktok.com")
      result.should eq(
        <<-JS
          return byted_acrawler.sign({ url: "http://tiktok.com" });
        JS
      )
    end
  end

  describe ".user_agent" do
    it "returns the user agent" do
      result = TiktokPassport::Javascript.user_agent
      result.should eq(
        <<-JS
          return navigator.userAgent;
        JS
      )
    end
  end
end
