require "./session/*"

module TiktokPassport
  module Signer
    class Session
      TARGET_URL = "about:blank"

      Log = ::Log.for(self)

      enum State
        Started
        Stopped
      end

      @marionette : Signer::Marionette?
      @remote_url : String

      def initialize(@remote_url)
        @mutex = Mutex.new
        @state = State::Stopped
      end

      def start
        @mutex.synchronize do
          Log.info { "Starting up a new Signer::Marionette session" }
          stop

          @marionette = protect_from_connection_error do
            Signer::Marionette.new(@remote_url)
          end

          if marionette = @marionette
            Log.info(&.emit("Started", id: marionette.id))
            transition_to(State::Started)

            Log.info(&.emit("Warming up", id: marionette.id))
            marionette.not_nil!.navigate_to(TARGET_URL)

            Log.info(&.emit("Ready", id: marionette.id))
          end
        end
      end

      def stop
        transition_to(State::Stopped)

        begin
          @marionette.not_nil!.stop
        rescue ex
        end
      end

      def sign(url) : String
        protect_from_connection_error do
          @marionette.not_nil!.evaluate(Javascript.sign(url))
        end
      end

      def navigator_info : Signer::NavigatorInfo
        protect_from_connection_error do
          @navigator_info ||=
            begin
              response = @marionette.not_nil!.evaluate(Javascript.navigator_info)
              Signer::NavigatorInfo.from_json(response)
            end
        end
      end

      def started?
        @state == State::Started
      end

      def stopped?
        @state == State::Stopped
      end

      private def transition_to(state : Session::State)
        @state = state
      end

      private def protect_from_connection_error
        yield
      rescue ex : Socket::Error | Socket::ConnectError | IO::Error | Selenium::Error
        raise Session::ConnectionLost.new
      end
    end
  end
end
