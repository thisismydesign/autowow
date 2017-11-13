module Autowow
  module Commands
    class Vcs
      def self.changes_not_on_remote(branch)
        ['git', 'log', branch, '--not', '--remotes']
      end

      def self.branches
        ["git for-each-ref --format='%(refname)' refs/heads/"]
        # TODO: report error with following command
        # ['git', 'for-each-ref', "--format='%(refname)'", 'refs/heads/']
      end

      def self.push
        ['git', 'push']
      end

      def self.rebase(branch)
        ['git', 'rebase', branch]
      end

      def self.status
        ['git', 'status']
      end

      def self.stash
        ['git', 'stash']
      end

      def self.stash_pop
        ['git', 'stash', 'pop']
      end

      def self.current_branch
        ['git', 'symbolic-ref', '--short', 'HEAD']
      end

      def self.checkout(existing_branch)
        ['git', 'checkout', existing_branch]
      end

      def self.pull
        ['git', 'pull']
      end

      def self.branch_force_delete(branch)
        ['git', 'branch', '-D', branch]
      end
    end
  end
end
