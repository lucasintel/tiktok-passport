module TiktokPassport
  module Signer
    class RequestSigner
      def initialize(@session : Session, url : String)
        @uri = URI.parse(url)
        @verify_fp = Utils.generate_verify_fp
      end

      def call : SignedRequest
        add_query_param("verifyFp", @verify_fp)
        verified_url = @uri.to_s

        # Uses the `window.byted_acrawler` function to sign the request.
        signature = @session.sign(verified_url)

        add_query_param("_signature", signature)
        signed_url = @uri.to_s

        SignedRequest.new(
          signed_at: Time.utc.to_unix_ms,
          user_agent: @session.user_agent,
          signature: signature,
          verify_fp: @verify_fp,
          signed_url: signed_url
        )
      end

      private def add_query_param(name, value) : Nil
        neo = @uri.query_params
        neo.delete_all(name)
        neo.add(name, value)

        @uri.query_params = neo
      end
    end
  end
end
