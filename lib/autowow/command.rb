require 'open3'

module Autowow
  class Command

    include EasyLogging

    def self.run(*args)
      Command.new(*args).explain.chronic_execute
    end

    def self.run_dry(*args)
      Command.new(*args).execute
    end

    def self.popen3_reader(*args)
      args.each do |arg|
        reader = <<-EOF
          def #{arg}
            @#{arg} = @#{arg}.read.rstrip unless @#{arg}.is_a?(String)
            return @#{arg}
          end
        EOF
        class_eval(reader)
      end
    end

    popen3_reader :stdin, :stdout, :stderr
    attr_reader :wait_thr

    def initialize(*args)
      @cmd = args
    end

    def explain
      logger.debug(@cmd.join(' ')) unless @cmd.empty?
      self
    end

    def execute
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*@cmd)
      self
    end

    def chronic_execute
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*@cmd)
      logger.error(stderr) unless stderr.empty?
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
