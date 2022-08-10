require "thor"

require_relative "executor"
require_relative "decorators/string_decorator"

require_relative "features/gem"
require_relative "features/vcs"
require_relative "features/os"
require_relative "features/fs"

require_relative "commands/gem"

module Autowow
  class CLI < Thor
    desc "branch_merged", "clean working branch and return to default branch"
    def branch_merged
      Autowow::Features::Vcs.branch_merged
    end
    map %w[bm] => :branch_merged

    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Features::Vcs.update_projects
    end
    map %w[up] => :update_projects

    desc "clear_branches", "removes unused branches"
    def clear_branches
      Autowow::Features::Vcs.clear_branches
    end
    map %w[cb] => :clear_branches

    desc "add_upstream", "adds upstream branch if available"
    def add_upstream
      Autowow::Features::Vcs.add_upstream
    end
    map %w[au] => :add_upstream

    desc "open", "opens project URL in browser"
    def open
      Autowow::Features::Vcs.open
    end

    desc "exec", "runs command"
    def exec(*cmd)
      Autowow::Executor.pretty_with_output.run(cmd)
    end

    desc "force_pull", "pulls branch from origin discarding local changes (including commits)"
    def force_pull
      Autowow::Features::Vcs.force_pull
    end
    map %w[fp] => :force_pull

    desc "local_changes", "Are there any local changes in the repo?"
    def local_changes
      Autowow::Features::Vcs.local_changes
    end
    map %w[lc] => :local_changes

    desc "projects", "Show projects' name, age, and whether there are local changes"
    def projects
      Autowow::Features::Vcs.projects
    end
    map %w[p] => :projects
  end
end
