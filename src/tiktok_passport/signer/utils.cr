module TiktokPassport
  module Signer
    module Utils
      VERIFY_FP_SEED = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

      # Generates a valid `verifyFp` using the Tiktok algorithm.
      # https://github.com/davidteather/TikTok-Api/issues/347
      def self.generate_verify_fp : String
        timestamp = Time.utc.to_unix_ms.to_s(36)
        uuid = StaticArray(Char, 36).new('0')

        uuid[8] = uuid[13] = uuid[18] = uuid[23] = '_'
        uuid[14] = '4'

        36.times do |index|
          next if uuid[index] != '0'

          random = (Random.rand * VERIFY_FP_SEED.size).to_i
          char_index = ((3 & random) | (index == 19 ? 8 : random)).to_i

          uuid[index] = VERIFY_FP_SEED[char_index]
        end

        "verify_#{timestamp.downcase}_#{uuid.join}"
      end
    end
  end
end
