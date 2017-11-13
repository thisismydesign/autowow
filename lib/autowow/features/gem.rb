require_relative '../commands/gem'

module Autowow
  module Features
    class Gem
      include EasyLogging
      extend Commands::Gem

      def self.gem_release
        start_status = Vcs.status
        logger.info(start_status)
        working_branch = Vcs.current_branch
        logger.error("Not on master.") and return unless working_branch.eql?('master')
        Vcs.push

        Vcs.on_branch('release') do
          Vcs.pull
          Vcs.rebase(working_branch)
          Command.run(release)
        end

        logger.info(Vcs.status)
      end

      def self.gem_clean
        Command.run(clean)
      end
    end
  end
end
