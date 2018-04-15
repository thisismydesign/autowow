require "thor"

require_relative "executor"
require_relative "decorators/string_decorator"

require_relative "features/rbenv"
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
    map %w[gc] => :gem_clean
    map %w[rv] => :ruby_versions
    map %w[gr] => :greet
    map %w[rpa] => :rubocop_parallel_autocorrect
    map %w[be] => :bundle_exec

    desc "branch_merged", "clean working branch and return to master"
    def branch_merged
      Autowow::Features::Vcs.branch_merged
    end

    desc "gem_release", "release gem and return to master"
    def gem_release
      Autowow::Features::Gem.gem_release
    end

    desc "update_projects", "updates idle projects"
    def update_projects
      Autowow::Features::Vcs.update_projects
    end

    desc "clear_branches", "removes unused branches"
    def clear_branches
      Autowow::Features::Vcs.clear_branches
    end

    desc "add_upstream", "adds upstream branch if available"
    def add_upstream
      Autowow::Features::Vcs.add_upstream
    end

    desc "hi", "day starter routine"
    def hi
      Autowow::Features::Vcs.hi
    end

    desc "hi!", "day starter routine for a new start"
    def hi!
      Autowow::Features::Vcs.hi!
    end

    desc "open", "opens project URL in browser"
    def open
      Autowow::Features::Vcs.open
    end

    desc "gem_clean", "cleans unused gems"
    def gem_clean
      Autowow::Features::Gem.gem_clean
    end

    desc "ruby_versions", "shows ruby versions in use"
    def ruby_versions
      Autowow::Features::Rbenv.ruby_versions
    end

    desc "greet", "shows report of repos"
    def greet
      Autowow::Features::Vcs.greet
    end

    desc "rubocop_parallel_autocorrect", "runs rubocop in parallel mode, autocorrects offenses on single thread"
    def rubocop_parallel_autocorrect
      Autowow::Features::Gem.rubocop_parallel_autocorrect
    end

    desc "exec", "runs command"
    def exec(*cmd)
      Autowow::Executor.pretty_with_output.run(cmd)
    end

    desc "bundle_exec", "runs command with `bundle exec` prefixed"
    def bundle_exec(*cmd)
      Autowow::Features::Gem.bundle_exec(cmd)
    end
  end
end
