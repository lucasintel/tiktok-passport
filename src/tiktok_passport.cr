require "json"
require "pool/connection"
require "router"
require "selenium"

require "./tiktok_passport/*"

module TiktokPassport
  def self.run
    pool = TiktokPassport::SessionPool.new
    server = TiktokPassport::Server.new(pool)

    server.run
  end
end
