module TiktokPassport
  module Signer
    struct SignedRequest
      include JSON::Serializable

      @signed_at : Int64 = Time.utc.to_unix_ms
      @signature : String
      @verify_fp : String
      @signed_url : String
      @navigator : Marionette::NavigatorInfo

      def initialize(@signature, @verify_fp, @signed_url, @navigator)
      end
    end
  end
end
