module Autowow
  module Commands
    module Gem
      def release
        ["rake", "release"]
      end

      def clean
        ["gem", "clean"]
      end

      def rubocop_parallel
        ["rubocop", "--parallel"]
      end

      def rubocop_autocorrect(files)
        if files.kind_of?(Array)
          ["rubocop", "--auto-correct"] + files
        else
          ["rubocop", "--auto-correct"] + files.split(" ")
        end
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
