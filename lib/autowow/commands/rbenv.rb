module Autowow
  module Commands
    module Rbenv
      def version
        ["rbenv", "local"]
      end

      def aliases
        ["rbenv", "alias"]
      end

      def installed_versions
        ["rbenv", "versions", "--bare", "--skip-aliases"]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
