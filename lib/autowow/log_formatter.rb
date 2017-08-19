require 'colorize'

module Autowow
  class LogFormatter
    def self.beautify(severity, msg)
      log_msg = "#{msg}#{$/}"
      log_msg = " $ #{log_msg}" if severity.eql?('DEBUG')
      color(severity, log_msg)
    end

    def self.color(severity, msg)
      case severity
      when 'DEBUG'
        msg.yellow
      when 'WARN'
        msg.orange
      when 'ERROR'
        msg.red
      else
        msg
      end
    end
  end
end
