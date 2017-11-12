require 'uri'
require 'net/https'
require 'net/http'
require 'json'
require 'launchy'

require_relative 'command'
require_relative 'decorators/string_decorator'
require_relative 'fs'
require_relative 'time_difference'
require_relative 'gem'
require_relative 'ruby'

module Autowow
  class Vcs
    include EasyLogging
    include StringDecorator

    using RefinedTimeDifference

    def self.branch_merged
      start_status = status
      logger.info(start_status)
      working_branch = current_branch
      logger.error("Nothing to do.") and return if working_branch.eql?('master')

      keep_changes do
        checkout('master')
        pull
      end
      branch_force_delete(working_branch)

      logger.info(status)
    end

    def self.update_projects
      Fs.in_place_or_subdirs(is_git?(status_dry)) do
        update_project
      end
    end

    def self.update_project
      start_status = status_dry
      return unless is_git?(start_status)
      logger.info("Updating #{File.expand_path('.')} ...")
      logger.warn("Skipped: uncommitted changes on master.") and return if uncommitted_changes?(start_status) and current_branch.eql?('master')

      on_branch('master') do
        has_upstream?(remotes.out) ? pull_upstream : pull
      end
    end

    def self.clear_branches
      logger.info(branch.out)
      working_branch = current_branch
      master_branch = 'master'

      (branches - [master_branch, working_branch]).each do |branch|
        branch_force_delete(branch) if branch_pushed(branch)
      end

      logger.info(branch.out)
    end

    def self.add_upstream
      start_status = status_dry
      logger.error("Not a git repository.") and return unless is_git?(start_status)
      remote_list = remotes.out
      logger.warn("Already has upstream.") and return if has_upstream?(remote_list)
      logger.info(remote_list)

      url = URI.parse(origin_push_url(remote_list))
      host = "api.#{url.host}"
      path = "/repos#{url.path}"
      request = Net::HTTP.new(host, url.port)
      request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request.use_ssl = url.scheme == 'https'
      response = request.get(path)

      if response.kind_of?(Net::HTTPRedirection)
        logger.error('Repository moved / renamed. Update remote or implement redirect handling. :)')
      elsif response.kind_of?(Net::HTTPNotFound)
        logger.error('Repository not found. Maybe it is private.')
      elsif response.kind_of?(Net::HTTPSuccess)
        parsed_response = JSON.parse(response.body)
        logger.warn('Not a fork.') and return unless parsed_response['fork']
        parent_url = parsed_response.dig('parent', 'html_url')
        add_remote('upstream', parent_url) unless parent_url.to_s.empty?
        logger.info(remotes.out)
      else
        logger.error("Github API (#{url.scheme}://#{host}#{path}) could not be reached: #{response.body}")
      end
    end

    def self.greet(latest_project_info = nil)
      logger.info("\nGood morning!\n\n")
      if is_git?(status_dry)
        logger.error('Inside repo, cannot show report about all repos.')
      else
        latest_project_info ||= get_latest_project_info
        logger.info(latest_project_info)
        check_projects_older_than(1, :months)
      end
      logger.info("\nThe following Ruby versions are not used by any projects, maybe consider removing them?\n  #{Ruby.obsolete_versions.join("\n  ")}")
    end

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
        logger.info(Gem.clean.out)
      end
    end

    def self.open
      Launchy.open(origin_push_url(remotes.out))
    end

    def self.get_latest_project_info
      latest = latest_repo
      time_diff = TimeDifference.between(File.mtime(latest), Time.now).humanize_higher_than(:days).downcase
      time_diff_text = time_diff.empty? ? 'recently' : "#{time_diff} ago"
      "It looks like you were working on #{File.basename(latest)} #{time_diff_text}.\n\n"
    end

    def self.latest_repo
      Fs.latest(git_projects)
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

    def self.stash
      Command.run('git', 'stash')
    end

    def self.current_branch
      Command.run_dry('git', 'symbolic-ref', '--short', 'HEAD').out
    end

    def self.status
      status = Command.run('git', 'status')
      status.out + status.err
    end

    def self.status_dry
      status = Command.run_dry('git', 'status')
      status.out + status.err
    end

    def self.checkout(existing_branch)
      Command.run('git', 'checkout', existing_branch)
    end

    def self.create(branch)
      Command.run('git', 'checkout', '-b', branch)
      Command.run('git', 'push', '--set-upstream', 'origin', branch)
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

    def self.has_upstream?(remotes)
      remotes.include?('upstream')
    end

    def self.uncommitted_changes?(start_status)
      !(start_status.include?('nothing to commit, working tree clean') or start_status.include?('nothing added to commit but untracked files present'))
    end

    def self.is_git?(start_status)
      !start_status.include?('Not a git repository')
    end

    def self.origin_push_url(remotes)
      # Order is important: first try to match "url" in "#{url}.git" as non-dot_git matchers would include ".git" in the match
      origin_push_url_ssl_dot_git(remotes) or
          origin_push_url_ssl(remotes)or
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

    def self.add_remote(name, url)
      Command.run('git', 'remote', 'add', name, url)
    end

    def self.on_branch(branch)
      keep_changes do
        working_branch = current_branch
        switch_needed = !working_branch.eql?(branch)
        if switch_needed
          result = checkout(branch)
          create(branch) if result.err.eql?("error: pathspec '#{branch}' did not match any file(s) known to git.")
        end

        yield

        checkout(working_branch) if switch_needed
      end
    end

    def self.keep_changes
      status = status_dry
      pop_stash = uncommitted_changes?(status)
      stash if pop_stash
      yield
      stash_pop if pop_stash
    end

    def self.git_projects
      Fs.ls_dirs.select do |dir|
        Dir.chdir(dir) do
          is_git?(status_dry)
        end
      end
    end

    def self.branch_pushed(branch)
      Command.run_dry('git', 'log', branch, '--not', '--remotes').out.empty?
    end

    def self.branches
      branches = Command.run_dry('git', 'for-each-ref', "--format='%(refname)'", 'refs/heads/').out
      branches.each_line.map { |line| line.strip[%r{(?<='refs/heads/)(.*)(?=')}] }
    end

    def self.push
      Command.run('git', 'push')
    end

    def self.rebase(branch)
      Command.run('git', 'rebase', branch)
    end

    # TODO: methods should return array of commands, way of execution should be determined by executor
  end
end
