require "pastel"

module Autowow
  class LogFormatter
    def self.beautify(severity, msg)
      log_msg = msg.to_s.end_with?($/) ? msg : "#{msg}#{$/}"
      log_msg = " $ #{log_msg}" if severity.eql?("DEBUG")
      color(severity, log_msg)
    end

    def self.color(severity, msg)
      pastel = Pastel.new
      case severity
      when "DEBUG"
        pastel.yellow(msg)
      when "WARN"
        pastel.red(msg)
      when "ERROR"
        pastel.bright_red(msg)
      else
        msg
      end
    end
  end
end
