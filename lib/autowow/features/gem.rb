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

      def gem_release(version = nil)
        pretty_with_output.run(git_status)
        start_branch = Vcs.working_branch
        logger.error("Not on master.") and return unless start_branch.eql?("master")
        pretty.run(pull)

        if version
          pretty_with_output.run(bump(version))
          update_readme_version_information(version)
          pretty.run(add(["README.md", "*version.rb"]))
          pretty.run(commit("Bumps version to v#{version}"))
        end

        pretty.run(push)

        Vcs.on_branch("release") do
          pretty.run(pull)
          pretty.run(rebase(start_branch))
          pretty_with_output.run(release)
        end

        pretty_with_output.run(git_status)
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

      def update_readme_version_information(version)
        readme = File.new("README.md")
        if File.file?(readme)
          text = File.read(readme)
          matches = text.match(/<!--- Version informartion -->(.+)<!--- Version informartion end -->/m)
          return if matches.length == 0
          version_information = matches[0]
      
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
      
          text.gsub!(version_information, new_version_information)
          File.write(readme, text)
        end
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
