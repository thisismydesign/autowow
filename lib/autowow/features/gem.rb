require_relative '../commands/gem'
require_relative 'vcs'

module Autowow
  module Features
    module Gem
      include EasyLogging
      include Commands::Gem
      include Commands::Vcs
      include Executor

      def gem_release
        pretty_with_output.run(git_status)
        start_branch = Vcs.working_branch
        logger.error("Not on master.") and return unless start_branch.eql?('master')
        pretty.run(push)

        Vcs.on_branch('release') do
          pretty.run(pull)
          pretty.run(rebase(start_branch))
          pretty_with_output.run(release)
        end

        pretty_with_output.run(git_status)
      end

      def gem_clean
        pretty_with_output.run(clean)
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
