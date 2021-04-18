require "./ext/pool"

module TiktokPassport
  class SessionPool
    POOL_CAPACITY = ENV.fetch("POOL_CAPACITY", "1").to_i
    POOL_TIMEOUT  = ENV.fetch("POOL_TIMEOUT", "10").to_f

    @pool : ConnectionPool(Session)

    def initialize
      @pool = ConnectionPool.new(capacity: POOL_CAPACITY, timeout: POOL_TIMEOUT) do
        Session.new(ENV["SELENIUM_BROWSER_URL"])
      end

      warm_up
    end

    def sign(url : String) : SignedRequest
      @pool.connection do |session|
        session.start

        uri = URI.parse(url)
        verify_fp = session.verify_fp

        set_query!(uri, name: "verifyFp", value: verify_fp)
        verified_url = uri.to_s

        signature = session.sign(verified_url)

        set_query!(uri, name: "_signature", value: signature)
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
        raise ex
      end
    end

    def stop
      until @pool.pending == @pool.size
        sleep 0.1
      end

      @pool.each_resource(&.stop)
    end

    private def set_query!(uri, name, value)
      new_params = uri.query_params
      new_params.delete_all(name)
      new_params.add(name, value)

      uri.query_params = new_params
    end

    # TODO: Refactor.
    private def warm_up
      sign("/")
    end
  end
end
