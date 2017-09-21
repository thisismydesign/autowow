require_relative 'time_difference'

module Autowow
  class Fs
    def self.ls_dirs
      Dir.glob(File.expand_path('./*/'))
    end

    def self.latest(files)
      files.sort_by{ |f| File.mtime(f) }.reverse!.first
    end

    def self.older_than(files, quantity, unit)
      files.select do |dir|
        TimeDifference.between(File.mtime(dir), Time.now).public_send("in_#{unit}") > quantity
      end
    end

    def self.for_dirs
      Fs.ls_dirs.each do |working_dir|
        # TODO: add handling of directories via extra param to popen3
        # https://stackoverflow.com/a/10148084/2771889
        Dir.chdir(working_dir) do
          yield working_dir
        end
      end
    end

    def self.in_place_or_subdirs(in_place)
      if in_place
        yield
      else
        for_dirs do
          yield
        end
      end
    end
  end
end
