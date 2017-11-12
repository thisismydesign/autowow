module Autowow
  module Commands
    class Rbenv
      def self.version
        ['rbenv', 'local']
      end

      def self.alias
        ['rbenv', 'alias']
      end

      def self.installed_versions
        ['rbenv', 'versions', '--bare', '--skip-aliases']
      end
    end
  end
end
