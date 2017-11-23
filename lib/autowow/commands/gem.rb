module Autowow
  module Commands
    module Gem
      def release
        ['rake', 'release']
      end

      def clean
        ['gem', 'clean']
      end

      def rubocop_parallel
        ['rubocop', '--parallel']
      end

      def rubocop_autocorrect(files)
        ['rubocop', '--auto-correct', files]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
