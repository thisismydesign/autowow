module Autowow
  module Commands
    module Gem
      def release
        be + ["rake", "release"]
      end

      def clean
        ["gem", "clean"]
      end

      def bundle_install
        ["bundle", "install"]
      end

      def bump(version = nil)
        command = ["gem", "bump", "--no-commit", "--no-color"]
        return command unless version
        command + ["--version", version]
      end

      def build(pattern)
        ["gem", "build"] + pattern
      end

      def be
        ["bundle", "exec"]
      end

      def rake
        be + ["rake"]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
