module Autowow
  module Commands
    module Vcs
      def self.changes_not_on_remote(branch)
        cmd + terminal_options + ["log", "--not", "--remotes", branch]
      end

      def self.branch_list
        cmd + ["for-each-ref", "--format='%(refname:short)'", "refs/heads/"]
      end

      def self.push(branch = nil, remote = nil)
        cmd + ["push"] + [branch, remote].compact
      end

      def self.status
        cmd + ["status"]
      end

      def self.stash
        cmd + ["stash"]
      end

      def self.stash_pop
        cmd + ["stash", "pop"]
      end

      def self.current_branch
        cmd + ["symbolic-ref", "--short", "HEAD"]
      end

      def self.symbolic_origin_head
        cmd + ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"]
      end

      def self.checkout(existing_branch)
        cmd + ["checkout", existing_branch]
      end

      def self.pull
        cmd + ["pull"]
      end

      def self.branch_force_delete(branch)
        cmd + ["branch", "-D", branch]
      end

      def self.create(branch)
        cmd + ["checkout", "-b", branch]
      end

      def self.remotes
        cmd + ["remote", "-v"]
      end

      def self.fetch(remote)
        cmd + ["fetch", remote]
      end

      def self.merge(compare)
        cmd + ["merge", compare]
      end

      def self.branch
        cmd + terminal_options + ["branch"]
      end

      def self.add_remote(name, url)
        cmd + ["remote", "add", name, url]
      end

      def self.hard_reset(branch)
        cmd + ["reset", "--hard", branch]
      end

      def self.upstream_tracking(branch)
        cmd + ["for-each-ref", "--format=%'(upstream:short)'", "refs/heads/#{branch}"]
      end

      private

      def self.cmd
        ["git"]
      end

      def self.terminal_options
        ["--no-pager"]
      end
    end
  end
end
