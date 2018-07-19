require "pastel"

require_relative "../commands/gem"
require_relative "vcs"

module Autowow
  module Features
    module Gem
      include EasyLogging
      include Commands::Gem
      include Commands::Vcs
      include Executor

      def gem_release(version_bump = nil)
        unless rubygems_credentials_set?
          logger.error("Set RubyGems credentials first via `gem push`")
          return
        end
        pretty_with_output.run(git_status)
        start_branch = Vcs.working_branch
        logger.error("Not on master.") and return unless start_branch.eql?("master")
        pretty.run(pull)
        version = nil

        if version_bump
          version = pretty_with_output.run(bump(version_bump)).out.clean_lines.select { |line| line.match(/Bumping|bump/) }.first.split(" ").last
          bump_readme_version_information(version)
          # Full command is needed because of faulty escaping otherwise
          pretty.run("git add README.md *version.rb")
          pretty.run("git commit -m \"Bumps version to v#{version}\"")
        end

        pretty.run(push)

        Vcs.on_branch("release") do
          pretty.run(pull)
          pretty.run(rebase(start_branch))
          pretty_with_output.run(release)
        end

        if version && change_readme_version_information_to_development(version)
          pretty.run(add(["README.md"]))
          # Full command is needed because of faulty escaping otherwise
          pretty.run("git commit -m \"Changes README to development version\"")
          pretty.run(push)
        end

        pretty_with_output.run(git_status)
      end

      def rubygems_credentials_set?
        !quiet.run!("gem push --silent").err.clean_lines.blank?
      end

      def gem_clean
        pretty_with_output.run(clean)
      end

      def rubocop_parallel_autocorrect
        pastel = Pastel.new
        result = pretty_with_output.run!(rubocop_parallel)
        if result.failed?
          filtered = result.out.each_line.select { |line| line.match(%r{(.*):([0-9]*):([0-9]*):}) }
                       .map { |line| line.split(":")[0] }
                       .uniq
                       .map { |line| pastel.strip(line) }
          pretty_with_output.run(rubocop_autocorrect(filtered)) if filtered.any?
        end
      end

      def bundle_exec(cmd)
        Autowow::Executor.pretty_with_output.run(["bundle", "exec"] + cmd)
      end

      def db_migrate
        pretty_with_output.run(rake_db_migrate)
      end

      def db_schema
        pretty_with_output.run(rake_db_schema)
      end

      def db_structure
        pretty_with_output.run(rake_db_structure)
      end

      def bump_readme_version_information(version)
        readme = "README.md"
        return unless File.exists?(readme)
        text = File.read(readme)
        return unless contains_version_information?(text)

        version_information = get_version_information(text)
    
        new_version_information = if version_information.include?("development version")
          releases_link = version_information.match(/\[.+\]\(.+\)/)[0].split("(")[1].split("/tag")[0]
          <<-HEREDOC
<!--- Version informartion -->
*You are viewing the README of version [v#{version}](#{releases_link}/tag/v#{version}). You can find other releases [here](#{releases_link}).*
<!--- Version informartion end -->
          HEREDOC
        else
          version_information.gsub(/[0-9]\.[0-9]\.[0-9]/, version)
        end
    
        text.gsub!(version_information, new_version_information.chomp)
        File.write(readme, text)
      end

      def change_readme_version_information_to_development(version)
        readme = "README.md"
        return false unless File.file?(readme)
        text = File.read(readme)
        return false unless contains_version_information?(text)
        version_information = get_version_information(text)
        return false if version_information.include?("development version")

        releases_link = version_information.match(/\[.+\]\(.+\)/)[0].split("(")[1].split("/tag")[0]

        new_version_information = <<-HEREDOC
<!--- Version informartion -->
*You are viewing the README of the development version. You can find the README of the latest release (v#{version}) [here](#{releases_link}/tag/v#{version}).*
<!--- Version informartion end -->
        HEREDOC

        text.gsub!(version_information, new_version_information.chomp)
        File.write(readme, text)
        true
      end

      def contains_version_information?(text)
        text.match(/<!--- Version informartion -->(.+)<!--- Version informartion end -->/m).length > 0
      end

      def get_version_information(text)
        text.match(/<!--- Version informartion -->(.+)<!--- Version informartion end -->/m)[0]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
