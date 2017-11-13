require_relative '../commands/gem'

module Autowow
  module Features
    module Gem
      include EasyLogging
      extend Commands::Gem

      def gem_release
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

      def gem_clean
        Command.run(clean)
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
