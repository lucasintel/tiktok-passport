module TiktokPassport
  module Signer
    module Javascript
      def self.sign(url : String) : String
        %Q[return byted_acrawler.sign({ url: "#{url}" });]
      end

      def self.register_function
        {{ read_file("#{__DIR__}/javascript/function.js") }}
      end
    end
  end
end
