require 'uri'
require 'net/https'
require 'net/http'
require 'json'

require_relative 'command'
require_relative 'decorators/string_decorator'
require_relative 'fs'
require_relative 'time_difference'

module Autowow
  class Vcs
    include EasyLogging
    include StringDecorator

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
      start_status = status_dry
      if is_git?(start_status)
        update_project
      else
        Fs.ls_dirs.each do |working_dir|
          # TODO: add handling of directories via extra param to popen3
          # https://stackoverflow.com/a/10148084/2771889
          Dir.chdir(working_dir) do
            logger.info("Updating #{working_dir} ...")
            update_project
          end
        end
      end
    end

    def self.update_project
      start_status = status_dry
      logger.warn("Skipped: not a git repository.") and return unless is_git?(start_status)
      logger.warn("Skipped: uncommitted changes on master.") and return if uncommitted_changes?(start_status) and current_branch.eql?('master')

      on_branch('master') do
        has_upstream?(remotes.stdout) ? pull_upstream : pull
      end
    end

    def self.clear_branches
      logger.info(branch.stdout)
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

      logger.info(branch.stdout)
    end

    def self.add_upstream
      start_status = status_dry
      logger.error("Not a git repository.") and return unless is_git?(start_status)
      remote_list = remotes.stdout
      logger.error("Already has upstream.") and return if has_upstream?(remote_list)
      logger.info(remote_list)

      url = URI.parse(origin_push_url(remote_list))
      host = "api.#{url.host}"
      path = "/repos#{url.path}"
      request = Net::HTTP.new(host, url.port)
      request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request.use_ssl = url.scheme == 'https'
      response = request.get(path)
      logger.error("Github API (#{url.scheme}://#{host}#{path}) could not be reached: #{response.body}") and return unless response.kind_of?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      logger.info('Not a fork.') and return unless parsed_response['fork']
      parent_url = parsed_response.dig('parent', 'html_url')
      add_remote('upstream', parent_url) unless parent_url.to_s.empty?

      logger.info(remotes.stdout)
    end

    def self.hi
      logger.info("\nHang on, your projects are being updated...\n\n")
      update_projects

      logger.info("\nGood morning!\n\n")

      latest = Fs.latest
      time_diff = TimeDifference.between(File.mtime(latest), Time.now).humanize_higher_than(:days).downcase
      time_diff_text = time_diff.empty? ? 'recently' : "#{time_diff} ago"
      logger.info("It looks like you were working on #{File.basename(latest)} #{time_diff_text}.\n\n")

      unit = 1
      quantity = :months
      old_projects = Fs.older_than(quantity, unit)
      logger.info("The following projects have not been touched for more than #{unit} #{quantity}, maybe consider removing them?") unless old_projects.empty?
      old_projects.each do |project|
        time_diff = TimeDifference.between(File.mtime(project), Time.now).humanize_higher_than(:weeks).downcase
        logger.info("  #{File.basename(project)} (#{time_diff})")
      end
    end

    def self.stash
      Command.run('git', 'stash').output_does_not_match?(%r{No local changes to save})
    end

    def self.current_branch
      Command.run_dry('git', 'symbolic-ref', '--short', 'HEAD').stdout
    end

    def self.status
      status = Command.run('git', 'status')
      status.stdout + status.stderr
    end

    def self.status_dry
      status = Command.run_dry('git', 'status')
      status.stdout + status.stderr
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
      origin_push_url_https(remotes) or origin_push_url_ssl(remotes)
    end

    def self.origin_push_url_https(remotes)
      remotes[%r{(?<=origin(\s))http(s?)://[a-zA-Z\-_./]*(?=(\s)\(push\))}]
    end

    def self.origin_push_url_ssl(remotes)
      url = remotes[%r{(?<=origin(\s)git@)[a-zA-Z\-_./:]*(?=(\.)git(\s)\(push\))}]
      "https://#{url.gsub(':', '/')}" if url
    end

    def self.add_remote(name, url)
      Command.run('git', 'remote', 'add', name, url)
    end

    def self.on_branch(branch)
      keep_changes do
        working_branch = current_branch
        switch_needed = !working_branch.eql?(branch)
        checkout(branch) if switch_needed

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
  end
end
