module Selenium
  class DocumentManager
    def execute_cdp(command, params = {} of String => String) : JSON::Any
      parameters = {
        cmd:    command,
        params: params,
      }

      data = command_handler.execute(:execute_cdp, path_variables, parameters)
      data["value"]
    end
  end
end
