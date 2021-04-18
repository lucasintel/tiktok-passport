require "./browser_pool/*"

module TiktokPassport
  class BrowserPool
    POOL_CAPACITY = ENV.fetch("POOL_CAPACITY", "1").to_i
    POOL_TIMEOUT  = ENV.fetch("POOL_TIMEOUT", "10").to_f

    @pool : ConnectionPool(Browser::RemoteChromeSession)

    def initialize
      @pool = ConnectionPool.new(capacity: POOL_CAPACITY, timeout: POOL_TIMEOUT) do
        Browser::RemoteChromeSession.new(ENV["SELENIUM_BROWSER_URL"])
      end
    end

    def sign(url : String) : SignedRequest
      @pool.connection do |session|
        begin
          verify_fp = session.verify_fp

          uri = URI.parse(url)
          query = uri.query_params

          query.delete_all("verifyFp")
          query.delete_all("_signature")

          query.add("verifyFp", verify_fp)
          uri.query_params = query
          verified_url = uri.to_s

          signature = session.sign(verified_url)

          query.add("_signature", signature)
          uri.query_params = query
          signed_url = uri.to_s

          SignedRequest.new(
            signed_at: Time.utc.to_unix_ms,
            user_agent: session.user_agent,
            signature: signature,
            verify_fp: verify_fp,
            signed_url: signed_url
          )
        rescue ex
          session.recycle
          sign(url)
        end
      end
    end
  end
end
