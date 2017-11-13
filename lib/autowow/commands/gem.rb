module Autowow
  module Commands
    module Gem
      def release
        ['rake', 'release']
      end

      def clean
        ['gem', 'clean']
      end
    end
  end
end
