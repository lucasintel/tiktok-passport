module TiktokPassport
  module Signer
    module Javascript
      def self.sign(url : String) : String
        <<-JS
          return byted_acrawler.sign({ url: "#{url}" });
        JS
      end
    end
  end
end
