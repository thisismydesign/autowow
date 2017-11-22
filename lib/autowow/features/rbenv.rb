require_relative '../commands/rbenv'
require_relative '../commands/vcs'

require_relative 'fs'
require_relative 'vcs'

module Autowow
  module Features
    module Rbenv
      include EasyLogging
      include Commands::Rbenv
      include Executor
      include StringDecorator

      def ruby_versions
        logger.info(used_versions)
      end

      def used_versions
        rubies = []
        Fs.in_place_or_subdirs(Vcs.is_git?) do
          result = quiet.run!(version)
          rubies.concat(result.out.clean_lines) if result.success?
        end
        rubies.uniq
      end

      def ruby_aliases
        ret = {}
        result = quiet.run!(aliases)
        return ret unless result.success?
        result.out.clean_lines.each do |line|
          ret[line.split(' => ')[0]] = line.split(' => ')[1]
        end
        ret
      end

      def obsolete_versions
        alias_map = ruby_aliases
        used_versions_and_aliases = used_versions
        used_versions.each do |v|
          used_versions_and_aliases.push(alias_map[v]) if alias_map.has_key?(v)
        end
        quiet.run(installed_versions).out.clean_lines - used_versions_and_aliases
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
