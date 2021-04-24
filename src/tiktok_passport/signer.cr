require "./signer/*"

module TiktokPassport
  module Signer
    @@pool = Marionette::Pool.new

    # Signs the given TikTok request *url*.
    def self.sign(url : String) : Signer::SignedRequest
      @@pool.with do |session|
        Signer::RequestSigner.new(session, url).call
      end
    end

    # Shutdown the marionette pool.
    def self.shutdown
      @@pool.shutdown
    end

    def self.warm_up
      sign("/")
    end
  end
end
