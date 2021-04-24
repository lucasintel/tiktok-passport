module Selenium
  module Chrome
    class Capabilities
      class ChromeOptions
        @[JSON::Field(key: "mobileEmulation")]
        property mobile_emulation = MobileEmulation.new

        @[JSON::Field(key: "excludeSwitches")]
        property exclude_switches : Array(String)?

        class MobileEmulation
          include JSON::Serializable

          def initialize
          end

          @[JSON::Field(key: "deviceName")]
          property device_name : String?
        end
      end
    end
  end
end
