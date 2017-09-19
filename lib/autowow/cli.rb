require 'thor'

require_relative 'vcs'
require_relative 'gem'

module Autowow
  class CLI < Thor

    map %w[bm] => :branch_merged
    map %w[grls] => :gem_release
    map %w[up] => :update_projects
    map %w[cb] => :clear_branches

    desc "branch_merged", "clean working branch and return to master"
    def branch_merged
      Autowow::Vcs.new.branch_merged
    end

    desc "gem_release", "release gem and return to master"
    def gem_release
      Autowow::Gem.gem_release
    end

    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Vcs.new.update_projects
    end

    desc "clear_branches", "removes unused branches"
    def clear_branches
      Autowow::Vcs.new.clear_branches
    end
  end
end
