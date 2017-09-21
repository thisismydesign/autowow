require_relative 'vcs'
require_relative 'command'

module Autowow
  class Gem
    include EasyLogging

    def self.gem_release
      start_status = Vcs.status
      logger.info(start_status)
      working_branch = Vcs.current_branch
      logger.error("Not on master.") and return unless working_branch.eql?('master')

      on_branch('release') do
        Vcs.pull
        Command.run('git', 'rebase', working_branch)
        release
      end

      logger.info(status)
    end

    def self.release
      Command.run('rake', 'release')
    end
  end
end
