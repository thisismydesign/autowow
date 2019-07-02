module Autowow
  module Commands
    module Vcs
      def cmd
        ["git"]
      end

      def terminal_options
        ["--no-pager"]
      end

      def commit (msg)
        cmd + ["commit", "-m", msg]
      end

      def changes_not_on_remote(branch)
        cmd + terminal_options + ["log", "--not", "--remotes", branch]
      end

      def branch_list
        cmd + ["for-each-ref", "--format='%(refname:short)'", "refs/heads/"]
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

      def merge(compare)
        cmd + ["merge", compare]
      end

      def branch
        cmd + terminal_options + ["branch"]
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

      def upstream_tracking(branch)
        cmd + ["for-each-ref", "--format=%'(upstream:short)'", "refs/heads/#{branch}"]
      end

      def current_ref
        cmd + ["symbolic-ref", "--quiet", "HEAD"]
      end

      def show_ref(branch)
        cmd + ["show-ref", branch]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
