require_relative '../commands/vcs'
require_relative 'fs'
require_relative 'rbenv'

module Autowow
  module Features
    class Vcs
      extend Commands::Vcs

      include EasyLogging

      using RefinedTimeDifference

      def self.branch_merged
        Command.run_with_output(git_status)
        working_branch = Command.run_dry(current_branch).out.strip
        logger.error("Nothing to do.") and return if working_branch.eql?('master')

        keep_changes do
          Command.run(checkout('master'))
          Command.run(pull)
        end
        Command.run(branch_force_delete(working_branch))

        Command.run_with_output(git_status)
      end

      def self.branch_pushed(branch)
        Command.run_dry(changes_not_on_remote(branch)).out.empty?
      end

      def self.greet(latest_project_info = nil)
        logger.info("\nGood morning!\n\n")
        if is_git?
          logger.error('Inside repo, cannot show report about all repos.')
        else
          latest_project_info ||= get_latest_repo_info
          logger.info(latest_project_info)
          check_projects_older_than(1, :months)
        end
        obsolete_rubies = Rbenv.obsolete_versions
        if obsolete_rubies.any?
          logger.info("\nThe following Ruby versions are not used by any projects, maybe consider removing them?")
          obsolete_rubies.each do |ruby_verion|
            logger.info("  #{ruby_verion}")
          end
        end
      end

      def self.check_projects_older_than(quantity, unit)
        old_projects = Fs.older_than(git_projects, quantity, unit)
        deprecated_projects = old_projects.reject do |project|
          Dir.chdir(project) { branches.reject{ |branch| branch_pushed(branch) }.any? }
        end

        logger.info("The following projects have not been touched for more than #{quantity} #{unit} and all changes have been pushed, maybe consider removing them?") unless deprecated_projects.empty?
        deprecated_projects.each do |project|
          time_diff = TimeDifference.between(File.mtime(project), Time.now).humanize_higher_than(:weeks).downcase
          logger.info("  #{File.basename(project)} (#{time_diff})")
        end
      end

      def self.get_latest_repo_info
        latest = latest_repo
        time_diff = TimeDifference.between(File.mtime(latest), Time.now).humanize_higher_than(:days).downcase
        time_diff_text = time_diff.empty? ? 'recently' : "#{time_diff} ago"
        "It looks like you were working on #{File.basename(latest)} #{time_diff_text}.\n\n"
      end

      def self.latest_repo
        Fs.latest(git_projects)
      end

      def self.branches
        Command.clean_lines(Command.run_dry(branch_list).out).each.map { |line| line[%r{(?<=refs/heads/)(.*)}] }
      end

      def self.uncommitted_changes?(status)
        !(status.include?('nothing to commit, working tree clean') or status.include?('nothing added to commit but untracked files present'))
      end

      def self.keep_changes
        status = Command.run_dry(git_status).out
        pop_stash = uncommitted_changes?(status)
        Command.run_dry(stash) if pop_stash
        begin
          yield if block_given?
        ensure
          Command.run_dry(stash_pop) if pop_stash
        end
      end

      def self.is_git?
        Fs.git_folder_present && Command.run_dry!(git_status).success?
      end

      def self.git_projects
        Fs.ls_dirs.select do |dir|
          Dir.chdir(dir) do
            is_git?
          end
        end
      end
    end
  end
end
