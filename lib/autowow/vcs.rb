require_relative 'command'

module Autowow
  class Vcs
    include EasyLogging

    def initialize
      # TODO make it configurable
      @working_dirs = Dir.glob(File.expand_path("~/repos/*/"))
    end

    def branch_merged(working_dir = '.')
      start_status = status.stdout
      logger.info(start_status)
      working_branch = current_branch
      logger.error("Nothing to do.") and return if working_branch.eql?('master')
      pop_stash = uncommitted_changes?(start_status)

      stash if pop_stash
      checkout('master')
      pull
      stash_pop if pop_stash
      branch_force_delete(working_branch)

      logger.info(status.stdout)
    end

    def gem_release(working_dir = '.')
      start_status = status.stdout
      logger.info(start_status)
      working_branch = current_branch
      logger.error("Not on master.") and return unless working_branch.eql?('master')
      pop_stash = uncommitted_changes?(start_status)

      stash if pop_stash
      Command.run('git', 'fetch', '--all')
      checkout('release')
      Command.run('git', 'rebase', working_branch)
      Command.run('rake', 'release')
      checkout('master')
      stash_pop if pop_stash

      logger.info(status.stdout)
    end

    def update_projects(working_dirs = @working_dirs)
      working_dirs.each do |working_dir|
        # TODO: add handling of directories via extra param to popen3
        # https://stackoverflow.com/a/10148084/2771889
        Dir.chdir(working_dir) {
          logger.info("Updating #{working_dir} ...")
          start_status = status_dry.stdout
          logger.error("Skipped: not a git repository.") and next unless is_git?(start_status)
          logger.error("Skipped: work in progress (not on master).") and next unless current_branch.eql?('master')
          logger.error("Skipped: work in progress (uncommitted changes).") and next if uncommitted_changes?(start_status)
          has_upstream? ? pull_upstream : pull
          logger.info("Done.")
        }
      end
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

    def status_dry
      Command.run_dry('git', 'status')
    end

    def checkout(existing_branch)
      Command.run('git', 'checkout', existing_branch)
    end

    def pull
      Command.run('git', 'pull')
    end

    def pull_upstream
      Command.run('git', 'fetch', 'upstream')
      Command.run('git', 'merge', 'upstream/master')
      Command.run('git', 'push', 'origin', 'master')
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

    def remotes
      Command.run('git', 'remote', '-v')
    end

    def has_upstream?
      remotes.stdout.include?('upstream')
    end

    def uncommitted_changes?(start_status)
      !start_status.include?('nothing to commit, working tree clean')
    end

    def is_git?(start_status)
      !start_status.include?('Not a git repository')
    end
  end
end
