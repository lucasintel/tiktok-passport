module TiktokPassport
  module Signer
    struct SignedRequest
      include JSON::Serializable

      @signed_at : Int64
      @user_agent : String
      @signature : String
      @verify_fp : String
      @signed_url : String

      def initialize(@signed_at, @user_agent, @signature, @verify_fp, @signed_url)
      end
    end
  end
end
