module Autowow
  module Commands
    module Gem
      def release
        be + ["rake", "release"]
      end

      def clean
        ["gem", "clean"]
      end

      def rubocop_parallel
        be + ["rubocop", "--parallel"]
      end

      def bump(version = nil)
        (["gem", "bump", "--no-commit"] + [version]).reject(&:nil?)
      end

      def rubocop_autocorrect(files)
        cmd = be + ["rubocop", "--auto-correct"]
        if files.kind_of?(Array)
          cmd + files
        else
          cmd + files.split(" ")
        end
      end

      def be
        ["bundle", "exec"]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
