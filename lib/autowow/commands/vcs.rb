module Autowow
  module Commands
    module Vcs
      def changes_not_on_remote(branch)
        ['git', 'log', branch, '--not', '--remotes']
      end

      def branch_list
        ["git for-each-ref --format='%(refname)' refs/heads/"]
        # TODO: report error with following command
        # ['git', 'for-each-ref', "--format='%(refname)'", 'refs/heads/']
      end

      def push
        ['git', 'push']
      end

      def rebase(branch)
        ['git', 'rebase', branch]
      end

      def git_status
        ['git', 'status']
      end

      def stash
        ['git', 'stash']
      end

      def stash_pop
        ['git', 'stash', 'pop']
      end

      def current_branch
        ['git', 'symbolic-ref', '--short', 'HEAD']
      end

      def checkout(existing_branch)
        ['git', 'checkout', existing_branch]
      end

      def pull
        ['git', 'pull']
      end

      def branch_force_delete(branch)
        ['git', 'branch', '-D', branch]
      end

      def create(branch)
        ['git', 'checkout', '-b', branch]
      end

      def set_upstream(remote, branch)
        ['git', 'push', '--set-upstream', remote, branch]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
