require "tty-command"

module Autowow
  module Executor
    class Pretty < TTY::Command::Printers::Pretty
      def print_command_out_data(cmd, *args); end
      def print_command_err_data(cmd, *args); end

      def print_command_exit(cmd, status, runtime, *args)
        super
        write("")
      end
    end

    class PrettyWithOutput < TTY::Command::Printers::Pretty
      def print_command_exit(cmd, status, runtime, *args)
        super
        write("")
      end
    end

    class RunWrapper
      def initialize(tty_command)
        @tty_command = tty_command
      end

      def run(array)
        @tty_command.run(*array)
      end

      def run!(array)
        @tty_command.run!(*array)
      end
    end

    def pretty
      @pretty ||= RunWrapper.new(TTY::Command.new(pty: true, printer: Pretty))
    end

    def pretty_with_output
      @pretty_with_output ||= RunWrapper.new(TTY::Command.new(pty: true, printer: PrettyWithOutput))
    end

    def quiet
      @quiet ||= RunWrapper.new(TTY::Command.new(pty: true, printer: :null))
    end

    include ReflectionUtils::CreateModuleFunctions
  end
end
