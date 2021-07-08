require_relative "../commands/os"

module Autowow
  module Features
    module Os
      include Commands::Os
      include Executor

      def exists?(cmd)
        Executor.quiet.run!(Commands::Os.which(cmd)).success?
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
