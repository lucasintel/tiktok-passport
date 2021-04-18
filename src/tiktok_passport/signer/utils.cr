module TiktokPassport
  module Signer
    module Utils
      # https://github.com/davidteather/TikTok-Api/issues/347
      def self.generate_verify_fp : String
        dict = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        dict_length = dict.size
        timestamp = Time.utc.to_unix_ms.to_s(36)
        uuid = Array.new(36, '0')

        uuid[8] = uuid[13] = uuid[18] = uuid[23] = '_'
        uuid[14] = '4'

        36.times do |index|
          next if uuid[index] != '0'

          random = (Random.rand * dict_length).to_i
          char_index = ((3 & random) | (index == 19 ? 8 : random)).to_i

          uuid[index] = dict[char_index]
        end

        "verify_#{timestamp.downcase}_#{uuid.join}"
      end
    end
  end
end
