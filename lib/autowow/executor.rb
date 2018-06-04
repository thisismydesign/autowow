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
      end

      def print_command_err_data(cmd, *args)
        @out << args.join(" ")
      end

      def print_command_exit(cmd, status, runtime, *args)
        @out.each_line.map(&:chomp).each { |line| write(cmd, line) }
        super
      end

      def write(cmd, message, data = nil)
        out = []
        out << "[#{decorate(cmd.uuid, :green)}] " unless cmd.uuid.nil?
        out << "#{message}\n"
        output << out.join
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

    def pretty
      @pretty ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: Pretty)))
    end

    def pretty_with_output
      @pretty_with_output ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: BufferingPretty)), fail_silently: true)
    end

    def quiet
      @quiet ||= RunWrapper.new(TTY::Command.new(tty_params.merge(printer: :null)))
    end

    def tty_params
      { pty: true, verbose: false }
    end

    include ReflectionUtils::CreateModuleFunctions
  end
end
