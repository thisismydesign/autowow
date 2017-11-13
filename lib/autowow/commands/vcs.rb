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
    end

    # TODO: do this pattern for all methods
    # https://stackoverflow.com/questions/322470/can-i-invoke-an-instance-method-on-a-ruby-module-without-including-it
    # https://stackoverflow.com/questions/10039039/why-self-method-of-module-cannot-become-a-singleton-method-of-class
    Vcs.module_eval do
      module_function(:current_branch)
      public(:current_branch)
    end
  end
end
