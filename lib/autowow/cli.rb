require 'thor'

require_relative 'vcs'

module Autowow
  class CLI < Thor

    map %w(bm)  => :branch_merged

    desc "branch_merged", "clean working branch and return to master"
    def branch_merged(working_dir = '.')
      Autowow::Vcs.new.branch_merged(working_dir)
    end
  end
end
