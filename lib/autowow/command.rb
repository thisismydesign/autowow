require 'open3'

module Autowow
  class Command

    def self.popen3_reader(*args)
      args.each do |arg|
        class_eval("def #{arg}; @#{arg} = @#{arg}.read.strip unless @#{arg}.is_a?(String); return @#{arg}; end")
      end
    end

    popen3_reader :stdin, :stdout, :stderr
    attr_reader :wait_thr

    def initialize *args
      @cmd = args
    end

    def execute
      p @cmd
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*@cmd)
      self
    end

    def output_matches?(matcher)
      stdout.match(matcher)
    end

    def output_does_not_match?(matcher)
      !output_matches?(matcher)
    end

  end
end
