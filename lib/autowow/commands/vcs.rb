module Autowow
  module Commands
    module Vcs
      def cmd
        ['git']
      end

      def default_options
        ['--no-pager']
      end

      def changes_not_on_remote(branch)
        cmd + default_options + ['log', branch, '--not', '--remotes']
      end

      def branch_list
        cmd + default_options + ['for-each-ref', "--format=%(refname)", 'refs/heads/']
      end

      def push(branch = nil, remote = nil)
        cmd + default_options + ['push'] + [branch, remote].compact
      end

      def rebase(branch)
        cmd + default_options + ['rebase', branch]
      end

      def git_status
        cmd + default_options + ['status']
      end

      def stash
        cmd + default_options + ['stash']
      end

      def stash_pop
        cmd + default_options + ['stash', 'pop']
      end

      def current_branch
        cmd + default_options + ['symbolic-ref', '--short', 'HEAD']
      end

      def checkout(existing_branch)
        cmd + default_options + ['checkout', existing_branch]
      end

      def pull
        cmd + default_options + ['pull']
      end

      def branch_force_delete(branch)
        cmd + default_options + ['branch', '-D', branch]
      end

      def create(branch)
        cmd + default_options + ['checkout', '-b', branch]
      end

      def set_upstream(remote, branch)
        cmd + default_options + ['push', '--set-upstream', remote, branch]
      end

      def remotes
        cmd + default_options + ['remote', '-v']
      end

      def fetch(remote)
        cmd + default_options + ['fetch', remote]
      end

      def merge(compare)
        cmd + default_options + ['merge', compare]
      end

      def branch
        cmd + default_options + ['branch']
      end

      def add_remote(name, url)
        cmd + default_options + ['remote', 'add', name, url]
      end

      include ReflectionUtils::CreateModuleFunctions
    end
  end
end
