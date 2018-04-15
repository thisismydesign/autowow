module Autowow
  module Commands
    module Os
      def which(cmd)
        ["which", cmd]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
