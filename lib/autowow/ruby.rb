module Autowow
  class Ruby
    include EasyLogging

    def self.versions
      rubies = []
      Fs.in_place_or_subdirs(Vcs.is_git?(Vcs.status_dry)) do
        rubies.push(version)
      end
      rubies.uniq!
      logger.info(rubies.to_s)
    end

    def self.version
      Command.run_dry('rbenv', 'local').stdout
    end
  end
end
