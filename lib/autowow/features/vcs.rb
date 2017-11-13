require_relative '../commands/vcs'
require_relative 'fs'

module Autowow
  module Features
    class Vcs
      def self.branch_pushed(branch)
        Command.run_dry(Commands::Vcs.changes_not_on_remote(branch)).out.empty?
      end

      def self.branches
        Command.clean_lines(Command.run_dry(Commands::Vcs.branches).out).each.map { |line| line[%r{(?<=refs/heads/)(.*)}] }
      end

      def self.uncommitted_changes?(status)
        !(status.include?('nothing to commit, working tree clean') or status.include?('nothing added to commit but untracked files present'))
      end

      def self.keep_changes
        status = Command.run_dry(Commands::Vcs.status).out
        pop_stash = uncommitted_changes?(status)
        Command.run_dry(Commands::Vcs.stash) if pop_stash
        begin
          yield if block_given?
        ensure
          Command.run_dry(Commands::Vcs.stash_pop) if pop_stash
        end
      end

      def self.is_git?(status)
        Fs.git_folder_present && !status.include?('Not a git repository')
      end

      def self.git_projects
        Fs.ls_dirs.select do |dir|
          Dir.chdir(dir) do
            is_git?(Command.run_dry(Commands::Vcs.status).out)
          end
        end
      end
    end
  end
end
