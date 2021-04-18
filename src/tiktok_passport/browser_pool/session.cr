module TiktokPassport
  module Browser
    abstract class Session
      abstract def sign(url : String) : String
      abstract def user_agent : String
    end
  end
end
