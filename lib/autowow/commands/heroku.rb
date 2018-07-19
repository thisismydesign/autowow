module Autowow
  module Commands
    module Heroku
      def cmd
        ["heroku"]
      end

      def info
        cmd + ["info"]
      end

      def pb_reset(app_name)
        cmd + ["pg:reset", "DATABASE_URL", "--app", app_name, "--confirm", app_name]
      end

      def migrate(app_name)
        cmd + ["run", "rake", "db:migrate", "--app", app_name]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
