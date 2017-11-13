require 'easy_logging'
require 'reflection_utils'

require_relative 'autowow/log_formatter'

EasyLogging.level = Logger::DEBUG
EasyLogging.formatter = proc do |severity, datetime, progname, msg|
  Autowow::LogFormatter.beautify(severity, msg)
end

require_relative 'autowow/cli'

module Autowow; end
