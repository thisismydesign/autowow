require "uri"
require "net/https"
require "net/http"
require "json"
require "launchy"

require_relative "../commands/vcs"
require_relative "fs"
require_relative "../time_difference"

module Autowow
  module Features
    module Vcs
      include EasyLogging
      include StringDecorator

      using RefinedTimeDifference

      def self.is_tracked?(branch)
        !Executor.quiet.run!(Commands::Vcs.upstream_tracking(branch).join(" ")).out.strip.empty?
      end

      def self.force_pull
        Executor.pretty_with_output.run(Commands::Vcs.status)
        branch = working_branch

        Executor.pretty_with_output.run(Commands::Vcs.fetch("--all"))
        Executor.pretty_with_output.run(Commands::Vcs.("origin/#{branch}"))

        Executor.pretty_with_output.run(Commands::Vcs.status)
      end

      def self.open
        url = origin_push_url(Executor.quiet.run(Commands::Vcs.remotes).out)
        logger.info("Opening #{url}")
        Launchy.open(url)
      end

      def self.add_upstream
        logger.error("Not a git repository.") and return unless is_git?
        logger.warn("Already has upstream.") and return if has_upstream?
        remote_list = Executor.pretty_with_output.run(Commands::Vcs.remotes).out

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
          Executor.pretty.run(Commands::Vcs.add_remote("upstream", parent_url)) unless parent_url.to_s.empty?
          Executor.pretty_with_output.run(Commands::Vcs.remotes)
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
        Executor.pretty_with_output.run(Commands::Vcs.branch)
        branch_removed = false

        (branches - [default_branch, working_branch]).each do |branch|
          if branch_pushed(branch)
            Executor.pretty.run(Commands::Vcs.branch_force_delete(branch))
            branch_removed = true
          end
        end

        Executor.pretty_with_output.run(Commands::Vcs.branch) if branch_removed
      end

      def self.update_projects
        Fs.in_place_or_subdirs(is_git?) do
          update_project
        end
      end

      def self.update_project
        logger.info("Updating #{File.expand_path('.')} ...")
        logger.error("Not a git repository.") and return unless is_git?
        status = Executor.quiet.run(Commands::Vcs.status).out
        if uncommitted_changes?(status) && working_branch.eql?(default_branch)
          logger.warn("Skipped: uncommitted changes on default branch.") and return
        end

        on_branch(default_branch) do
          has_upstream? ? pull_upstream : Executor.pretty_with_output.run(Commands::Vcs.pull)
        end
      end

      def self.pull_upstream
        upstream_remote = "upstream"
        remote = "origin"
        branch = default_branch
        Executor.pretty_with_output.run(Commands::Vcs.fetch(upstream_remote)).out
        Executor.pretty_with_output.run(Commands::Vcs.merge("#{upstream_remote}/#{branch}")).out
        Executor.pretty_with_output.run(Commands::Vcs.push(remote, branch))
      end

      def self.has_upstream?
        Executor.quiet.run(Commands::Vcs.remotes).out.include?("upstream")
      end

      def self.on_branch(branch)
        keep_changes do
          start_branch = working_branch
          switch_needed = !start_branch.eql?(branch)
          if switch_needed
            result = Executor.pretty.run!(Commands::Vcs.checkout(branch))
            Executor.pretty.run(Commands::Vcs.create(branch)) unless result.success?
          end

          begin
            yield if block_given?
          ensure
            Executor.pretty.run(Commands::Vcs.checkout(start_branch)) if switch_needed
          end
        end
      end

      def self.branch_merged
        Executor.pretty_with_output.run(Commands::Vcs.status)
        branch = working_branch
        tagret_branch = default_branch
        logger.error("Nothing to do.") and return if branch.eql?(tagret_branch)

        keep_changes do
          Executor.pretty_with_output.run(Commands::Vcs.checkout(tagret_branch))
          Executor.pretty_with_output.run(Commands::Vcs.pull)
        end
        Executor.pretty_with_output.run(Commands::Vcs.branch_force_delete(branch))

        Executor.pretty_with_output.run(Commands::Vcs.status)
      end

      def self.working_branch
        Executor.quiet.run(Commands::Vcs.current_branch).out.strip
      end

      def self.default_branch
        Executor.quiet.run(Commands::Vcs.symbolic_origin_head).out.strip.split('/').last
      end

      def self.branch_pushed(branch, quiet = true)
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

      def self.commits_pushed?(branch)
        Executor.quiet.run(Commands::Vcs.changes_not_on_remote(branch)).out.strip.empty?
      end

      def self.projects
        git_projects.each do |git_project|
          age = Features::Fs.age(git_project).humanize_higher_than(:days).downcase
          logger.info("#{File.basename(git_project)} | last modified #{age.empty? ? 'recently': age + ' ago'} | local changes? #{local_changes?(git_project)}")
        end
      end

      def self.local_changes?(git_project)
        Dir.chdir(git_project) { any_branch_not_pushed? || uncommitted_changes?(Executor.quiet.run(Commands::Vcs.status).out) }
      end

      def self.any_branch_not_pushed?(quiet: true)
        branches.reject { |branch| branch_pushed(branch, quiet) }.any?
      end

      def self.latest_repo
        Fs.latest(git_projects)
      end

      def self.branches
        Executor.quiet.run(Commands::Vcs.branch_list.join(" ")).out.clean_lines
      end

      def self.local_changes
        changes = false
        status = Executor.quiet.run(Commands::Vcs.status).out
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

      def self.uncommitted_changes?(status)
        !(status.include?("nothing to commit, working tree clean") or status.include?("nothing added to commit but untracked files present") or status.include?("nothing to commit, working directory clean"))
      end

      def self.keep_changes
        status = Executor.quiet.run(Commands::Vcs.status).out
        pop_stash = uncommitted_changes?(status)
        Executor.quiet.run(Commands::Vcs.stash) if pop_stash
        begin
          yield if block_given?
        ensure
          Executor.quiet.run(Commands::Vcs.stash_pop) if pop_stash
        end
      end

      def self.is_git?
        status = Executor.quiet.run!(Commands::Vcs.status)
        Fs.git_folder_present && status.success? && !status.out.include?("Initial commit")
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
