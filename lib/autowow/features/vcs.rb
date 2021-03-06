require "uri"
require "net/https"
require "net/http"
require "json"
require "launchy"

require_relative "../commands/vcs"
require_relative "fs"
require_relative "rbenv"
require_relative "gem"
require_relative "../time_difference"

module Autowow
  module Features
    module Vcs
      include EasyLogging
      include Commands::Vcs
      include Executor
      include StringDecorator

      using RefinedTimeDifference

      def self.hi!
        logger.error("In a git repository. Try 1 level higher.") && return if is_git?
        hi do
          logger.info("Removing unused branches...")
          clear_branches
          logger.info("Adding upstream...")
          add_upstream
          logger.info("Removing unused gems...")
          Gem.gem_clean
        end
      end

      def self.hi
        logger.error("In a git repository. Try 1 level higher.") && return if is_git?
        latest_project_info = get_latest_repo_info
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

      def is_tracked?(branch)
        !quiet.run!(Vcs.upstream_tracking(branch).join(" ")).out.strip.empty?
      end

      def self.force_pull
        pretty_with_output.run(git_status)
        branch = working_branch

        pretty_with_output.run(fetch("--all"))
        pretty_with_output.run(hard_reset("origin/#{branch}"))

        pretty_with_output.run(git_status)
      end

      def self.open
        url = origin_push_url(quiet.run(remotes).out)
        logger.info("Opening #{url}")
        Launchy.open(url)
      end

      def self.add_upstream
        logger.error("Not a git repository.") and return unless is_git?
        logger.warn("Already has upstream.") and return if has_upstream?
        remote_list = pretty_with_output.run(remotes).out

        url = URI.parse(origin_push_url(remote_list))
        host = "api.#{url.host}"
        path = "/repos#{url.path}"
        request = Net::HTTP.new(host, url.port)
        request.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request.use_ssl = url.scheme == "https"
        logger.info("Fetching repo info from #{host}#{path}\n\n")
        response = request.get(path)

        if response.kind_of?(Net::HTTPRedirection)
          logger.error("Repository moved / renamed. Update remote or implement redirect handling. :)")
        elsif response.kind_of?(Net::HTTPNotFound)
          logger.error("Repository not found. Maybe it is private.")
        elsif response.kind_of?(Net::HTTPSuccess)
          parsed_response = JSON.parse(response.body)
          logger.warn("Not a fork.") and return unless parsed_response["fork"]
          parent_url = parsed_response.dig("parent", "html_url")
          pretty.run(add_remote("upstream", parent_url)) unless parent_url.to_s.empty?
          pretty_with_output.run(remotes)
        else
          logger.error("Github API (#{url.scheme}://#{host}#{path}) could not be reached: #{response.body}")
        end
      end

      def self.origin_push_url(remotes)
        # Order is important: first try to match "url" in "#{url}.git" as non-dot_git matchers would include ".git" in the match
        origin_push_url_ssl_dot_git(remotes) or
          origin_push_url_ssl(remotes) or
          origin_push_url_https_dot_git(remotes) or
          origin_push_url_https(remotes)
      end

      def self.origin_push_url_https(remotes)
        remotes[%r{(?<=origin(\s))http(s?)://[a-zA-Z\-_./]*(?=(\s)\(push\))}]
      end

      def self.origin_push_url_https_dot_git(remotes)
        remotes[%r{(?<=origin(\s))http(s?)://[a-zA-Z\-_./]*(?=(\.)git(\s)\(push\))}]
      end

      def self.origin_push_url_ssl_dot_git(remotes)
        url = remotes[%r{(?<=origin(\s)git@)[a-zA-Z\-_./:]*(?=(\.)git(\s)\(push\))}]
        "https://#{url.gsub(':', '/')}" if url
      end

      def self.origin_push_url_ssl(remotes)
        url = remotes[%r{(?<=origin(\s)git@)[a-zA-Z\-_./:]*(?=(\s)\(push\))}]
        "https://#{url.gsub(':', '/')}" if url
      end

      def self.clear_branches
        pretty_with_output.run(branch)
        branch_removed = false

        (branches - ["master", working_branch]).each do |branch|
          if branch_pushed(branch)
            pretty.run(branch_force_delete(branch))
            branch_removed = true
          end
        end

        pretty_with_output.run(branch) if branch_removed
      end

      def update_projects
        Fs.in_place_or_subdirs(is_git?) do
          update_project
        end
      end

      def update_project
        logger.info("Updating #{File.expand_path('.')} ...")
        logger.error("Not a git repository.") and return unless is_git?
        status = quiet.run(git_status).out
        if uncommitted_changes?(status) && working_branch.eql?("master")
          logger.warn("Skipped: uncommitted changes on master.") and return
        end

        on_branch("master") do
          has_upstream? ? pull_upstream : pretty_with_output.run(pull)
        end
      end

      def pull_upstream
        upstream_remote = "upstream"
        remote = "origin"
        branch = "master"
        pretty_with_output.run(fetch(upstream_remote)).out
        pretty_with_output.run(merge("#{upstream_remote}/#{branch}")).out
        pretty_with_output.run(push(remote, branch))
      end

      def has_upstream?
        quiet.run(remotes).out.include?("upstream")
      end

      def on_branch(branch)
        keep_changes do
          start_branch = working_branch
          switch_needed = !start_branch.eql?(branch)
          if switch_needed
            result = pretty.run!(checkout(branch))
            pretty.run(create(branch)) unless result.success?
          end

          begin
            yield if block_given?
          ensure
            pretty.run(checkout(start_branch)) if switch_needed
          end
        end
      end

      def branch_merged
        pretty_with_output.run(git_status)
        branch = working_branch
        logger.error("Nothing to do.") and return if branch.eql?("master")

        keep_changes do
          pretty_with_output.run(checkout("master"))
          pretty_with_output.run(pull)
        end
        pretty_with_output.run(branch_force_delete(branch))

        pretty_with_output.run(git_status)
      end

      def working_branch
        quiet.run(current_branch).out.strip
      end

      def branch_pushed(branch, quiet = true)
        if !is_tracked?(branch)
          logger.info("Branch `#{branch}` is not tracked.") unless quiet
          return false
        end

        if !commits_pushed?(branch)
          logger.info("Branch `#{branch}` is not pushed.") unless quiet
          return false
        end

        return true
      end

      def commits_pushed?(branch)
        quiet.run(changes_not_on_remote(branch)).out.strip.empty?
      end

      def greet(latest_project_info = nil)
        logger.info("\nGood morning!\n\n")
        if is_git?
          logger.error("Inside repo, cannot show report about all repos.")
        else
          latest_project_info ||= get_latest_repo_info
          logger.info(latest_project_info)
          check_projects_older_than(1, :months)
        end

        return unless Rbenv.exists?

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
          Dir.chdir(project) { any_branch_not_pushed? || uncommitted_changes?(quiet.run(git_status).out) }
        end

        logger.info("The following projects have not been touched for more than #{quantity} #{unit} and all changes have been pushed, maybe consider removing them?") unless deprecated_projects.empty?
        deprecated_projects.each do |project|
          time_diff = TimeDifference.between(File.mtime(project), Time.now).humanize_higher_than(:weeks).downcase
          logger.info("  #{File.basename(project)} (#{time_diff})")
        end
      end

      def any_branch_not_pushed?(quiet: true)
        branches.reject { |branch| branch_pushed(branch, quiet) }.any?
      end

      def get_latest_repo_info
        latest = latest_repo
        time_diff = TimeDifference.between(File.mtime(latest), Time.now).humanize_higher_than(:days).downcase
        time_diff_text = time_diff.empty? ? "recently" : "#{time_diff} ago"
        "It looks like you were working on #{File.basename(latest)} #{time_diff_text}.\n\n"
      end

      def latest_repo
        Fs.latest(git_projects)
      end

      def branches
        quiet.run(branch_list.join(" ")).out.clean_lines
      end

      def local_changes
        changes = false
        status = quiet.run(git_status).out
        if uncommitted_changes?(status)
          logger.info("There are uncommitted changes.")
          changes = true
        end

        if any_branch_not_pushed?(quiet: false)
          logger.info("There are unpushed changes.")
          changes = true
        end

        logger.info("No unpushed changes.") unless changes
      end

      def uncommitted_changes?(status)
        !(status.include?("nothing to commit, working tree clean") or status.include?("nothing added to commit but untracked files present") or status.include?("nothing to commit, working directory clean"))
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
        status = quiet.run!(git_status)
        Fs.git_folder_present && status.success? && !status.out.include?("Initial commit")
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
