module TiktokPassport
  class Marionette
    struct NavigatorInfo
      include JSON::Serializable

      getter user_agent : String
      getter browser_name : String
      getter browser_version : String
      getter browser_language : String
      getter browser_platform : String
      getter screen_width : Int32
      getter screen_height : Int32
    end
  end
end
