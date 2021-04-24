require "./default_commands"

module Selenium
  class CommandHandler
    def execute(command, path_variables : Hash(String, String) = {} of String => String, parameters = {} of String => String) : JSON::Any
      method, path = CUSTOM_COMMANDS[command]? || DEFAULT_COMMANDS[command]
      full_path = path_variables.reduce(path) { |acc, entry| acc.sub(entry.first, entry.last) }

      execute(method, full_path, parameters.to_json)
    end
  end
end
