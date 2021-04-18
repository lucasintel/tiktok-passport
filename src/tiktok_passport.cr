require "http/server"
require "json"
require "pool/connection"
require "selenium"

require "./tiktok_passport/*"

module TiktokPassport
  Log = ::Log.for(self)

  enum Control
    Start
    Stop
    Done
  end

  def self.run
    signal = Channel(Control).new
    server = Server.new

    {% for signal in %w[TERM INT] %}
      Signal::{{signal.id}}.trap do
        Log.info { "[SIG{{signal.id}}] Received graceful stop" }
        server.shutdown
        Signer.shutdown

        signal.send(Control::Done)
      end
    {% end %}

    Signer.warm_up
    server.start

    signal.receive
  end
end
