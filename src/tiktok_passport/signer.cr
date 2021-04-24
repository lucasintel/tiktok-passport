require "./signer/*"

module TiktokPassport
  module Signer
    @@pool = Marionette::Pool.new

    def self.sign(url : String) : SignedRequest
      @@pool.with do |session|
        Signer::RequestSigner.new(session, url).call
      end
    end

    def self.shutdown
      @@pool.shutdown
    end

    def self.warm_up
      sign("/")
    end
  end
end
