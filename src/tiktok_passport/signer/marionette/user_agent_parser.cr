module TiktokPassport
  module Signer
    class UserAgentParser
      SEPARATORS = [' ', ' ', ';']
      SEED       = [
        [0, 1, 2],
        [0, 2, 1],
        [1, 0, 2],
        [1, 2, 0],
        [2, 0, 1],
        [2, 1, 0],
      ]

      def initialize(@user_agent : String)
      end

      def brands
        [
          {brand: greasey_brand, version: "99"},
          {brand: "Chromium", version: chrome_major_version},
          {brand: "Google Chrome", version: chrome_major_version},
        ]
      end

      def full_version
        @user_agent
      end

      def platform
        "Windows"
      end

      def platform_version
        @user_agent.match(/Windows .*?([\d|.]+);/).not_nil![1]
      end

      def architecture
        "x86"
      end

      def model
        ""
      end

      def mobile
        false
      end

      private def greasey_brand
        String.build do |str|
          str << SEPARATORS[sprout[0]]
          str << "Not"
          str << SEPARATORS[sprout[1]]
          str << "A"
          str << SEPARATORS[sprout[2]]
          str << "Brand"
        end
      end

      private def chrome_version
        @user_agent.match(/Chrome\/([\d|.]+)/).not_nil![1]
      end

      private def chrome_major_version
        chrome_version.split('.').first
      end

      private def sprout
        SEED[chrome_major_version.to_i % 6]
      end
    end
  end
end
