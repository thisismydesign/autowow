require_relative '../commands/gem'
require_relative 'fs'

# TODO
module Autowow
  module Features
    module Gem
      include EasyLogging
      include Commands::Gem
      include Commands::Vcs
      include Executor

      def gem_release
        pretty_with_output.run(git_status)
        working_branch = quiet.run(current_branch).out.strip
        logger.error("Not on master.") and return unless working_branch.eql?('master')
        push

        Vcs.on_branch('release') do
          pull
          rebase(working_branch)
          Command.run(release)
        end

        pretty_with_output.run(git_status)
      end

      def gem_clean
        Command.run(clean)
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
