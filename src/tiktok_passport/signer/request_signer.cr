module TiktokPassport
  module Signer
    class RequestSigner
      def initialize(@session : Signer::Session, url : String)
        @uri = URI.parse(url)
        @verify_fp = Utils.generate_verify_fp
      end

      def call : SignedRequest
        add_query_param("verifyFp", @verify_fp)

        # Uses the `window.byted_acrawler` function to sign the request.
        verified_url = @uri.to_s
        signature = @session.sign(verified_url)

        add_query_param("_signature", signature)

        SignedRequest.new(
          signature: signature,
          verify_fp: @verify_fp,
          signed_url: @uri.to_s,
          navigator: @session.navigator_info,
        )
      end

      private def add_query_param(name, value) : Nil
        new_uri = @uri.query_params
        new_uri.delete_all(name)
        new_uri.add(name, value)

        @uri.query_params = new_uri
      end
    end
  end
end
