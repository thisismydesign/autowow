module Autowow
  module Commands
    module Vcs
      def cmd
        ["git"]
      end

      def terminal_options
        ["--no-pager"]
      end

      def commit(msg, options = [])
        cmd + ["commit", "-m", msg] + options
      end

      def changes_not_on_remote(branch)
        cmd + terminal_options + ["log", branch, "--not", "--remotes"]
      end

      def branch_list
        cmd + ["for-each-ref", "--format=%(refname)", "refs/heads/"]
      end

      def push(branch = nil, remote = nil)
        cmd + ["push"] + [branch, remote].compact
      end

      def rebase(branch)
        cmd + ["rebase", branch]
      end

      def git_status
        cmd + ["status"]
      end

      def stash
        cmd + ["stash"]
      end

      def stash_pop
        cmd + ["stash", "pop"]
      end

      def current_branch
        cmd + ["symbolic-ref", "--short", "HEAD"]
      end

      def first_commit(branch = "HEAD")
        cmd + ["rev-list", "--max-parents=0", branch]
      end

      def checkout(existing_branch)
        cmd + ["checkout", existing_branch]
      end

      def pull
        cmd + ["pull"]
      end

      def branch_force_delete(branch)
        cmd + ["branch", "-D", branch]
      end

      def create(branch)
        cmd + ["checkout", "-b", branch]
      end

      def set_upstream(remote, branch)
        cmd + ["push", "--set-upstream", remote, branch]
      end

      def remotes
        cmd + ["remote", "-v"]
      end

      def fetch(remote)
        cmd + ["fetch", remote]
      end

      def merge(compare, options = [])
        cmd + ["merge"] + options + [compare]
      end

      def branch
        cmd + ["branch"]
      end

      def add_remote(name, url)
        cmd + ["remote", "add", name, url]
      end

      def add(patterns)
        cmd + ["add"] + patterns
      end

      def hard_reset(branch)
        cmd + ["reset", "--hard", branch]
      end

      # Doesn't work on Windows
      def current_branch_remote
        cmd + ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
