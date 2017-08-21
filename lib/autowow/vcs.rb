require_relative 'command'

module Autowow
  class Vcs
    include EasyLogging

    def initialize
      # TODO make it configurable
      @working_dirs = Dir.glob '~/repos/*/'
    end

    def branch_merged(working_dir = '.')
      logger.info(status.stdout)
      working_branch = current_branch

      logger.error("#{$/}Nothing to do.") and return if working_branch.eql?('master')

      pop_stash = stash
      checkout('master')
      pull
      stash_pop if pop_stash
      branch_force_delete(working_branch)

      logger.info(status.stdout)
    end

    def stash
      Command.run('git', 'stash').output_does_not_match?(%r{No local changes to save})
    end

    def current_branch
      Command.run_dry('git', 'symbolic-ref', '--short', 'HEAD').stdout
    end

    def status
      Command.run('git', 'status')
    end

    def checkout(existing_branch)
      Command.run('git', 'checkout', existing_branch)
    end

    def pull
      Command.run('git', 'pull')
    end

    def branch
      Command.run('git', 'branch')
    end

    def stash_pop
      Command.run('git', 'stash', 'pop')
    end

    def branch_force_delete(branch)
      Command.run('git', 'branch', '-D', branch)
    end
  end
end
