require_relative '../commands/vcs'
require_relative 'fs'
require_relative 'rbenv'

module Autowow
  module Features
    module Vcs
      include EasyLogging
      include Commands::Vcs
      include Executor
      include StringDecorator

      using RefinedTimeDifference

      def branch_merged
        pretty_with_output.run(git_status)
        working_branch = quiet.run(current_branch).out.strip
        logger.error("Nothing to do.") and return if working_branch.eql?('master')

        keep_changes do
          pretty.run(checkout('master'))
          pretty.run(pull)
        end
        pretty.run(branch_force_delete(working_branch))

        pretty_with_output.run(git_status)
      end

      def branch_pushed(branch)
        quiet.run(changes_not_on_remote(branch)).out.empty?
      end

      def greet(latest_project_info = nil)
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

      def check_projects_older_than(quantity, unit)
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

      def get_latest_repo_info
        latest = latest_repo
        time_diff = TimeDifference.between(File.mtime(latest), Time.now).humanize_higher_than(:days).downcase
        time_diff_text = time_diff.empty? ? 'recently' : "#{time_diff} ago"
        "It looks like you were working on #{File.basename(latest)} #{time_diff_text}.\n\n"
      end

      def latest_repo
        Fs.latest(git_projects)
      end

      def branches
        quiet.run(branch_list).out.clean_lines.map { |line| line[%r{(?<=refs/heads/)(.*)}] }
      end

      def uncommitted_changes?(status)
        !(status.include?('nothing to commit, working tree clean') or status.include?('nothing added to commit but untracked files present'))
      end

      def keep_changes
        status = quiet.run(git_status).out
        pop_stash = uncommitted_changes?(status)
        quiet.run(stash) if pop_stash
        begin
          yield if block_given?
        ensure
          quiet.run(stash_pop) if pop_stash
        end
      end

      def is_git?
        Fs.git_folder_present && quiet.run!(git_status).success?
      end

      def git_projects
        Fs.ls_dirs.select do |dir|
          Dir.chdir(dir) do
            is_git?
          end
        end
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
