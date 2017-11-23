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

      def rubocop_parallel_autocorrect
        result = pretty_with_output.run!(rubocop_parallel)
        if result.failed?
          filtered = result.out.each_line.select { |line| line.match(%r{(.*):([0-9]*):([0-9]*):}) }.map{ |line| line.split(':')[0] }.uniq
          pretty_with_output.run(rubocop_autocorrect(filtered)) if filtered.any?
        end
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
