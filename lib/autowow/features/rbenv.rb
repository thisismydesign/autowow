require_relative '../commands/rbenv'
require_relative '../commands/vcs'

require_relative 'fs'

module Autowow
  module Features
    class Rbenv
      def self.ruby_versions
        logger.info(used_versions)
      end

      def self.used_versions
        rubies = []
        Fs.in_place_or_subdirs(Vcs.is_git?) do
          result = Command.run_dry(Commands::Rbenv.version).out
          rubies.concat(Command.clean_lines(result))
        end
        rubies.uniq
      end

      def self.aliases
        aliases = {}
        Command.clean_lines(Command.run_dry(Commands::Rbenv.alias).out).each do |line|
          aliases[line.split(' => ')[0]] = line.split(' => ')[1]
        end
        aliases
      end

      def self.obsolete_versions
        alias_map = aliases
        used_versions_and_aliases = used_versions
        used_versions.each do |v|
          used_versions_and_aliases.push(alias_map[v]) if alias_map.has_key?(v)
        end
        Command.clean_lines(Command.run_dry(Commands::Rbenv.installed_versions).out) - used_versions_and_aliases
      end
    end
  end
end
