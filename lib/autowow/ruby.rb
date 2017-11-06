module Autowow
  class Ruby
    include EasyLogging

    def self.used_versions
      rubies = []
      Fs.in_place_or_subdirs(Vcs.is_git?(Vcs.status_dry)) do
        rubies.push(version)
      end
      rubies.uniq
    end

    def self.version
      Command.run_dry('rbenv', 'local').stdout
    end

    def self.installed_versions
      Command.run_dry('rbenv', 'versions', '--bare', '--skip-aliases').stdout.each_line.map(&:strip)
    end

    def self.aliases
      aliases = {}
      Command.run_dry('rbenv', 'alias').stdout.each_line do |line|
        aliases[line.strip.split(' => ')[0]] = line.strip.split(' => ')[1]
      end
      aliases
    end

    def self.obsolete_versions
      alias_map = aliases
      used_versions_and_aliases = used_versions
      used_versions.each do |v|
        used_versions_and_aliases.push(alias_map[v]) if alias_map.has_key?(v)
      end
      installed_versions - used_versions_and_aliases
    end
  end
end
