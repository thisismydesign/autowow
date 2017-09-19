require_relative 'vcs'
require_relative 'command'

module Autowow
  class Gem
    include EasyLogging

    def self.gem_release
      start_status = Vcs.status.stdout
      logger.info(start_status)
      working_branch = Vcs.current_branch
      logger.error("Not on master.") and return unless working_branch.eql?('master')
      pop_stash = Vcs.uncommitted_changes?(start_status)

      Vcs.stash if pop_stash
      Command.run('git', 'fetch', '--all')
      Vcs.checkout('release')
      Command.run('git', 'rebase', working_branch)
      release
      Vcs.checkout('master')
      Vcs.stash_pop if pop_stash

      logger.info(status.stdout)
    end

    def self.release
      Command.run('rake', 'release')
    end
  end
end
