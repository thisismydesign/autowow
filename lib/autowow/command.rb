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

    def self.run_with_output(args)
      @@pretty_executer.run(*args)
    end

    def self.run(args)
      @@simple_executer.run(*args)
    end

    def self.run_dry(args)
      @@quiet_executer.run(*args)
    end

    def self.run_dry!(args)
      @@quiet_executer.run!(*args)
    end

    def self.clean_lines(text)
      text.each_line.map(&:strip).reject(&:empty?)
    end

    def self.exists?(cmd)
      @@quiet_executer.run!('which', cmd).success?
    end
  end
end
