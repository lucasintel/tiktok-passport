module TiktokPassport
  module Signer
    module Javascript
      def self.sign(url : String) : String
        %Q[return byted_acrawler.sign({ url: "#{url}" });]
      end
    end
  end
end
