module Autowow
  module Commands
    class Gem
      def self.release
        ['rake', 'release']
      end

      def self.clean
        ['gem', 'clean']
      end
    end
  end
end
