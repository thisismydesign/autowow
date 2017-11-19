

require_relative 'features/fs'
require_relative 'time_difference'
require_relative 'commands/gem'
require_relative 'commands/rbenv'

module Autowow
  class Vcs
    include EasyLogging
    include StringDecorator

    using RefinedTimeDifference









    def self.hi
      logger.error("In a git repository. Try 1 level higher.") && return if is_git?(status_dry)
      latest_project_info = get_latest_project_info
      logger.info("\nHang on, updating your local projects and remote forks...\n\n")
      git_projects.each do |project|
        Dir.chdir(project) do
          logger.info("\nGetting #{project} in shape...")
          yield if block_given?
          update_project
        end
      end
      greet(latest_project_info)
    end

    def self.hi!
      logger.error("In a git repository. Try 1 level higher.") && return if is_git?(status_dry)
      hi do
        logger.info('Removing unused branches...')
        clear_branches
        logger.info('Adding upstream...')
        add_upstream
        logger.info('Removing unused gems...')
        Command.run_with_output(Commands::Gem.clean)
      end
    end



    def self.stash_pop
      Command.run(['git', 'stash', 'pop'])
    end










  end
end
