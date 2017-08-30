require 'thor'

require_relative 'vcs'

module Autowow
  class CLI < Thor

    map %w[bm] => :branch_merged
    map %w[grls] => :gem_release
    map %w[up] => :update_projects

    desc "branch_merged", "clean working branch and return to master"
    def branch_merged(working_dir = '.')
      Autowow::Vcs.new.branch_merged(working_dir)
    end

    desc "gem_release", "release gem and return to master"
    def gem_release(working_dir = '.')
      Autowow::Vcs.new.gem_release(working_dir)
    end

    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Vcs.new.update_projects
    end
  end
end
