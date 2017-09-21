require_relative 'time_difference'

module Autowow
  class Fs
    def self.ls_dirs
      Dir.glob(File.expand_path('./*/'))
    end

    def self.latest
      ls_dirs.sort_by{ |f| File.mtime(f) }.reverse!.first
    end

    def self.older_than(unit, quantity)
      ls_dirs.select do |dir|
        TimeDifference.between(File.mtime(dir), Time.now).public_send("in_#{unit}") > quantity
      end
    end
  end
end
