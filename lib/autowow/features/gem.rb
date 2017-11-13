require_relative '../commands/gem'

# TODO
module Autowow
  module Features
    module Gem
      include EasyLogging
      include Commands::Gem
      include Commands::Vcs
      include Features::Vcs

      def gem_release
        Command.run_with_output(git_status)
        working_branch = Command.run_dry(current_branch).out.strip
        logger.error("Not on master.") and return unless working_branch.eql?('master')
        push

        on_branch('release') do
          pull
          rebase(working_branch)
          Command.run(release)
        end

        Command.run_with_output(git_status)
      end

      def gem_clean
        Command.run(clean)
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
