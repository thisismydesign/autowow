require_relative 'command'

module Autowow
  class Vcs
    include EasyLogging

    def initialize
      # TODO make it configurable
      @working_dirs = Dir.glob '~/repos/*/'
    end

    def branch_merged(working_dir = '.')
      working_branch = Command.run_dry('git', 'symbolic-ref', '--short', 'HEAD').stdout
      return if working_branch.eql?('master')

      pop_stash = Command.run('git', 'stash').output_does_not_match?(%r{No local changes to save})
      Command.run('git', 'checkout', 'master')
      Command.run('git', 'pull')
      Command.run('git', 'stash', 'pop') if pop_stash
      Command.run('git', 'branch', '-D', working_branch)
      logger.info(Command.run('git', 'branch').stdout)
      logger.info(Command.run('git', 'status').stdout)
    end
  end
end
