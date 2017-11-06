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
  end
end
