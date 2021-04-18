module TiktokPassport
  module Javascript
    def self.get_cookie(name : String) : String
      <<-JS
        return (function (cookieName) {
          var cookieString = RegExp(cookieName+"=[^;]+").exec(document.cookie);
          return decodeURIComponent(!!cookieString ? cookieString.toString().replace(/^[^=]+./, "") : "");
        })("#{name}");
      JS
    end

    def self.sign(url : String) : String
      <<-JS
        return byted_acrawler.sign({ url: "#{url}" });
      JS
    end

    def self.user_agent
      <<-JS
        return navigator.userAgent;
      JS
    end
  end
end
