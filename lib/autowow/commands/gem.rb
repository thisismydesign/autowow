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

      def rubocop_parallel
        be + ["rubocop", "--parallel"]
      end

      def bump(version = nil)
        command = ["gem", "bump", "--no-commit", "--no-color"]
        return command unless version
        command + ["--version", version]
      end

      def rubocop_autocorrect(files)
        cmd = be + ["rubocop", "--auto-correct"]
        if files.kind_of?(Array)
          cmd + files
        else
          cmd + files.split(" ")
        end
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
