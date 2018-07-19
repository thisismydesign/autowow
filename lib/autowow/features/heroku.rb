require_relative "../commands/heroku"

module Autowow
  module Features
    module Gem
      include Commands::Heroku
      include Executor

      def app_name
        quiet.run(info).out.clean_lines.select { |line| line.start_with?("===") }.first.split(" ").last
      end

      def db_migrate
        current_app_name = app_name

        pretty_with_output.run(pb_reset(current_app_name))
        pretty_with_output.run(migrate(current_app_name))
      end
    end
  end
end
