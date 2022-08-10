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
    map %w[bm] => :branch_merged
    map %w[grls] => :gem_release
    map %w[up] => :update_projects
    map %w[cb] => :clear_branches
    map %w[au] => :add_upstream
    map %w[be] => :bundle_exec
    map %w[fp] => :force_pull
    map %w[lc] => :local_changes
    map %w[p] => :projects

    # keep
    desc "branch_merged", "clean working branch and return to default branch"
    def branch_merged
      Autowow::Features::Vcs.branch_merged
    end

    desc "gem_release", "release gem and return to default branch"
    def gem_release(version_bump = nil)
      Autowow::Features::Gem.gem_release(version_bump)
    end

    # keep
    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Features::Vcs.update_projects
    end

    # keep
    desc "clear_branches", "removes unused branches"
    def clear_branches
      Autowow::Features::Vcs.clear_branches
    end

    # keep
    desc "add_upstream", "adds upstream branch if available"
    def add_upstream
      Autowow::Features::Vcs.add_upstream
    end

    # keep
    desc "open", "opens project URL in browser"
    def open
      Autowow::Features::Vcs.open
    end

    # keep
    desc "exec", "runs command"
    def exec(*cmd)
      Autowow::Executor.pretty_with_output.run(cmd)
    end

    # keep
    desc "force_pull", "pulls branch from origin discarding local changes (including commits)"
    def force_pull
      Autowow::Features::Vcs.force_pull
    end

    # keep
    desc "local_changes", "Are there any local changes in the repo?"
    def local_changes
      Autowow::Features::Vcs.local_changes
    end

    desc "projects", "Show projects' name, age, and whether there are local changes"
    def projects
      Autowow::Features::Vcs.projects
    end
  end
end
