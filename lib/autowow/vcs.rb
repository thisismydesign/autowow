require_relative 'command'

module Autowow
  class Vcs
    include EasyLogging

    def initialize
      # TODO make it configurable
      @working_dirs = Dir.glob '~/repos/*/'
    end

    def branch_merged(working_dir)
      pop_stash = Command.new(['git', 'stash']).execute.output_does_not_match?(%r{No local changes to save})
      working_branch = Command.new(['git', 'symbolic-ref', '--short', 'HEAD']).execute.stdout
      Command.new(['git', 'checkout', 'master']).execute
      Command.new(['git', 'pull']).execute
      Command.new(['git', 'stash', 'pop']).execute if pop_stash
      Command.new(['git', 'branch', '-D', working_branch]).execute
      logger.info(Command.new(['git', 'status']).execute.stdout)
    end
  end
end
