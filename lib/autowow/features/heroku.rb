require_relative "../commands/heroku"

module Autowow
  module Features
    module Heroku
      include Commands::Heroku
      include Executor

      def app_name
        lines = quiet.run(info).out.clean_lines
        lines.select { |line| line.start_with?("===") }.first.split(" ").last
      end

      def pg_db_reset
        current_app_name = app_name

        pretty_with_output.run(pb_reset(current_app_name))
      end

      def db_migrate
        current_app_name = app_name

        pretty_with_output.run(migrate(current_app_name))
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
