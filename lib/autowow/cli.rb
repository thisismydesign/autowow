require 'thor'

require_relative 'vcs'
require_relative 'gem'

module Autowow
  class CLI < Thor

    map %w[bm] => :branch_merged
    map %w[grls] => :gem_release
    map %w[up] => :update_projects
    map %w[cb] => :clear_branches
    map %w[au] => :add_upstream

    desc "branch_merged", "clean working branch and return to master"
    def branch_merged
      Autowow::Vcs.branch_merged
    end

    desc "gem_release", "release gem and return to master"
    def gem_release
      Autowow::Gem.gem_release
    end

    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Vcs.update_projects
    end

    desc "clear_branches", "removes unused branches"
    def clear_branches
      Autowow::Vcs.clear_branches
    end

    desc "add_upstream", "adds upstream branch if available"
    def add_upstream
      Autowow::Vcs.add_upstream
    end

    desc "hi", "day starter routine"
    def hi
      Autowow::Vcs.hi
    end

    desc "hi!", "day starter routine for a new start"
    def hi!
      Autowow::Vcs.hi!
    end

    desc "open", "opens project URL in browser"
    def open
      Autowow::Vcs.open
    end

    desc "clean", "cleans sproject"
    def clean
      Autowow::Gem.clean
    end
  end
end
