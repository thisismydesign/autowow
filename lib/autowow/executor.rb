require "tty-command"

module Autowow
  module Executor
    class Pretty < TTY::Command::Printers::Pretty
      def print_command_out_data(cmd, *args); end
      def print_command_err_data(cmd, *args); end

      def print_command_exit(cmd, status, runtime, *args)
        super
        write(TTY::Command::Cmd.new("dummy"), "")
      end
    end

    class PrettyWithOutput < TTY::Command::Printers::Pretty
      def print_command_exit(cmd, status, runtime, *args)
        super
        write(TTY::Command::Cmd.new("dummy"), "")
      end
    end

    class BufferingPretty < TTY::Command::Printers::Pretty
      def initialize(*)
        super
        @out = ""
      end

      def print_command_out_data(cmd, *args)
        @out << args.join(" ")
        return unless multiple_lines?(@out)
        finished_lines(@out).each { |line| write(cmd, line) }
        @out = unfinished_line(@out)
      end
      alias_method :print_command_err_data, :print_command_out_data

      def print_command_exit(cmd, status, runtime, *args)
        @out.each_line.map(&:chomp).each { |line| write(cmd, line) }
        super
        write(TTY::Command::Cmd.new("dummy"), "", false)
      end

      def write(cmd, message, uuid_needed = true)
        out = []
        out << "[#{decorate(cmd.uuid, :green)}] " if uuid_needed && !cmd.uuid.nil?
        out << "#{message}\n"
        output << out.join
      end

      def finished_lines(string)
        string.each_line.to_a[0..-2].map(&:chomp)
      end

      def unfinished_line(string)
        string.each_line.to_a[-1]
      end

      def multiple_lines?(string)
        string.each_line.count > 1
      end
    end

    class RunWrapper
      def initialize(tty_command, fail_silently: false)
        @tty_command = tty_command
        @fail_silently = fail_silently
      end

      def run(array)
        begin
          @tty_command.run(*array)
        rescue TTY::Command::ExitError => e
          raise e unless @fail_silently
          exit 1
        end
      end

      def run!(array)
        @tty_command.run!(*array)
      end
    end

    def self.pretty
      @pretty ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: Pretty)))
    end

    def self.pretty_with_output
      @pretty_with_output ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: BufferingPretty)), fail_silently: true)
    end

    def self.quiet
      @quiet ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: :null)))
    end

    def self.tty_params
      { pty: true, verbose: false }
    end
  end
end
