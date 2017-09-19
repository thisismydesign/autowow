require_relative 'command'
require_relative 'decorators/string_decorator'

module Autowow
  class Vcs
    include EasyLogging
    include StringDecorator

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

    def update_projects
      Dir.glob(File.expand_path('.')).each do |working_dir|
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

    def clear_branches(working_dir = '.')
      logger.info(Command.run('git', 'branch').stdout)
      working_branch = current_branch
      master_branch = 'master'

      local_branches = Command.run('git', 'for-each-ref', "--format='%(refname)'", 'refs/heads/').stdout
      local_branches.each_line do |line|
        local_branch = line.strip.reverse_chomp("'refs/heads/").chomp("'")
        next if local_branch.eql?(master_branch) or local_branch.eql?(working_branch)
        if Command.run_dry('git', 'log', local_branch, '--not', '--remotes').stdout.empty?
          branch_force_delete(local_branch)
        end
      end

      logger.info(Command.run('git', 'branch').stdout)
    end

    def self.stash
      Command.run('git', 'stash').output_does_not_match?(%r{No local changes to save})
    end

    def self.current_branch
      Command.run_dry('git', 'symbolic-ref', '--short', 'HEAD').stdout
    end

    def self.status
      Command.run('git', 'status')
    end

    def self.status_dry
      Command.run_dry('git', 'status')
    end

    def self.checkout(existing_branch)
      Command.run('git', 'checkout', existing_branch)
    end

    def self.pull
      Command.run('git', 'pull')
    end

    def self.pull_upstream
      Command.run('git', 'fetch', 'upstream')
      Command.run('git', 'merge', 'upstream/master')
      Command.run('git', 'push', 'origin', 'master')
    end

    def self.branch
      Command.run('git', 'branch')
    end

    def self.stash_pop
      Command.run('git', 'stash', 'pop')
    end

    def self.branch_force_delete(branch)
      Command.run('git', 'branch', '-D', branch)
    end

    def self.remotes
      Command.run_dry('git', 'remote', '-v')
    end

    def self.has_upstream?
      remotes.stdout.include?('upstream')
    end

    def self.uncommitted_changes?(start_status)
      !(start_status.include?('nothing to commit, working tree clean') or start_status.include?('nothing added to commit but untracked files present'))
    end

    def self.is_git?(start_status)
      !start_status.include?('Not a git repository')
    end
  end
end
