module Selenium
  module DefaultCommands
    CUSTOM_COMMANDS = {
      execute_cdp: {:post, "/session/:session_id/goog/cdp/execute"},
    }
  end
end
