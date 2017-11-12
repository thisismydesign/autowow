require 'open3'
require 'tty-command'

module Autowow
  class Simple < TTY::Command::Printers::Pretty
    def print_command_out_data(cmd, *args); end
    def print_command_err_data(cmd, *args); end
    def print_command_exit(cmd, status, runtime, *args)
      super
      write('')
    end
  end

  class Full < TTY::Command::Printers::Pretty
    def print_command_exit(cmd, status, runtime, *args)
      super
      write('')
    end
  end

  class Command
    include EasyLogging

    @@simple_executer = TTY::Command.new(printer: Simple)
    @@pretty_executer = TTY::Command.new(printer: Full)
    @@quiet_executer = TTY::Command.new(printer: :null)
    @@progress_executer = TTY::Command.new(printer: :progress)

    def self.run(*args)
      # explain(args)
      @@simple_executer.run(*args)
      # Command.new(*args).check.explain.chronic_execute
    end

    def self.run_dry(*args)
      @@quiet_executer.run(*args)
      # Command.new(*args).silent_check.execute
    end

    # def self.popen3_reader(*args)
    #   args.each do |arg|
    #     reader = <<-EOF
    #       def #{arg}
    #         @#{arg} = @#{arg}.read.rstrip unless @#{arg}.is_a?(String)
    #         return @#{arg}
    #       end
    #     EOF
    #     class_eval(reader)
    #   end
    # end

    # popen3_reader :stdin, :stdout, :stderr
    # attr_reader :wait_thr

    # def initialize(*args)
    #   @cmd = args
    # end

    # def self.explain(cmd)
    #   logger.debug(cmd.join(' ')) unless cmd.empty?
    # end
    #
    # def execute
    #   @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*@cmd) unless @cmd.empty?
    #   self
    # end
    #
    # def chronic_execute
    #   @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(*@cmd) unless @cmd.empty?
    #   logger.error(stderr) unless stderr.empty?
    #   self
    # end

    # def silent_check
    #   @stdin, @stdout, @stderr, @wait_thr = Open3.popen3('which', @cmd[0])
    #   unless out.match(not_empty_matcher)
    #     yield if block_given?
    #     @cmd = []
    #   end
    #   self
    # end
    #
    # def check
    #   silent_check do
    #     logger.info("Skipping '#{@cmd.join(' ')}' because command '#{@cmd[0]}' is not found.")
    #   end
    # end

    # def output_matches?(matcher)
    #   stdout.match(matcher)
    # end
    #
    # def output_does_not_match?(matcher)
    #   !output_matches?(matcher)
    # end

    # def not_empty_matcher
    #   %r{.*\S.*}
    # end
  end
end
