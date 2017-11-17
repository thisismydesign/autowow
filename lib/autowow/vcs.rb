require 'uri'
require 'net/https'
require 'net/http'
require 'json'
require 'launchy'

require_relative 'features/fs'
require_relative 'time_difference'
require_relative 'commands/gem'
require_relative 'commands/rbenv'

module Autowow
  class Vcs
    include EasyLogging
    include StringDecorator

    using RefinedTimeDifference





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

    def self.open
      Launchy.open(origin_push_url(remotes.out))
    end



    def self.branch
      Command.run(['git', 'branch'])
    end

    def self.stash_pop
      Command.run(['git', 'stash', 'pop'])
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
      Command.run(['git', 'remote', 'add', name, url])
    end


  end
end
