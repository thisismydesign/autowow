# Disable warnings on console from dependencies: https://bloggie.io/@kinopyo/how-to-fix-ruby-2-7-warning-using-the-last-argument-as-keyword-parameters-is-deprecated
if RUBY_VERSION >= "2.7"
  Warning[:deprecated] = false
end

require "easy_logging"
require "reflection_utils"

require_relative "autowow/log_formatter"

EasyLogging.level = Logger::DEBUG
EasyLogging.formatter = proc do |severity, datetime, progname, msg|
  Autowow::LogFormatter.beautify(severity, msg)
end

require_relative "autowow/cli"

module Autowow; end
