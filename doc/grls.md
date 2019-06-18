# Gem release

`aw grls` / `autowow gem_release`

Prerequisites: on master

* `bundle install`
* `git pull`
* If [version parameter](https://github.com/svenfuchs/gem-release#options-1) is provided
  * Bumps version in version.rb
  * Bumps version information in README if present
  * `git add README.md *version.rb`
  * `git commit -m "Bumps version to <version>"`
* `git push`
* `git checkout release`
* `git pull`
* `git rebase master`
* `rake release`
* If [version parameter](https://github.com/svenfuchs/gem-release#options-1) is provided
  * Changes version information to development in README if present
  * `git add README.md`
  * `git commit -m "Changes README to development version"`
  * `git push`

```
$ aw grls minor
[1962e066] Running git status
[1962e066] On branch master
[1962e066] Your branch is up to date with 'origin/master'.
[1962e066] 
[1962e066] Untracked files:
[1962e066]   (use "git add <file>..." to include in what will be committed)
[1962e066] 
[1962e066]      autowow-0.14.3.gem
[1962e066] 
[1962e066] nothing added to commit but untracked files present (use "git add" to track)
[1962e066] Finished in 0.004 seconds with exit status 0 (successful)

[0bc9fca5] Running bundle install
[0bc9fca5] nothing added to commit but untracked files present (use "git add" to track)
[0bc9fca5] Using rake 10.5.0
[0bc9fca5] Using concurrent-ruby 1.1.5
[0bc9fca5] Using i18n 1.6.0
[0bc9fca5] Using minitest 5.11.3
[0bc9fca5] Using thread_safe 0.3.6
[0bc9fca5] Using tzinfo 1.2.5
[0bc9fca5] Using activesupport 5.2.3
[0bc9fca5] Using public_suffix 3.1.0
[0bc9fca5] Using addressable 2.6.0
[0bc9fca5] Using ast 2.4.0
[0bc9fca5] Using easy_logging 0.4.0
[0bc9fca5] Using gem-release 2.0.1
[0bc9fca5] Using launchy 2.4.3
[0bc9fca5] Using equatable 0.6.0
[0bc9fca5] Using tty-color 0.5.0
[0bc9fca5] Using pastel 0.7.3
[0bc9fca5] Using reflection_utils 0.3.0
[0bc9fca5] Using jaro_winkler 1.5.3
[0bc9fca5] Using parallel 1.17.0
[0bc9fca5] Using parser 2.6.3.0
[0bc9fca5] Using rainbow 3.0.0
[0bc9fca5] Using ruby-progressbar 1.10.1
[0bc9fca5] Using unicode-display_width 1.6.0
[0bc9fca5] Using rubocop 0.71.0
[0bc9fca5] Using rubocop-rspec 1.33.0
[0bc9fca5] Using thor 0.19.4
[0bc9fca5] Using time_difference 0.5.0
[0bc9fca5] Using tty-command 0.8.2
[0bc9fca5] Using autowow 0.14.3 from source at `.`
[0bc9fca5] Using bundler 1.17.2
[0bc9fca5] Using coderay 1.1.2
[0bc9fca5] Using json 2.1.0
[0bc9fca5] Using docile 1.3.1
[0bc9fca5] Using simplecov-html 0.10.2
[0bc9fca5] Using simplecov 0.16.1
[0bc9fca5] Using tins 1.18.0
[0bc9fca5] Using term-ansicolor 1.7.0
[0bc9fca5] Using coveralls 0.8.22
[0bc9fca5] Using diff-lcs 1.3
[0bc9fca5] Using ffi 1.9.25
[0bc9fca5] Using formatador 0.2.5
[0bc9fca5] Using rb-fsevent 0.10.3
[0bc9fca5] Using rb-inotify 0.9.10
[0bc9fca5] Using ruby_dep 1.5.0
[0bc9fca5] Using listen 3.1.5
[0bc9fca5] Using lumberjack 1.0.13
[0bc9fca5] Using nenv 0.3.0
[0bc9fca5] Using shellany 0.0.1
[0bc9fca5] Using notiffany 0.1.1
[0bc9fca5] Using method_source 0.9.1
[0bc9fca5] Using pry 0.12.0
[0bc9fca5] Using guard 2.14.2
[0bc9fca5] Using guard-compat 1.2.1
[0bc9fca5] Using guard-bundler 2.1.0
[0bc9fca5] Using rspec-support 3.8.0
[0bc9fca5] Using rspec-core 3.8.0
[0bc9fca5] Using rspec-expectations 3.8.2
[0bc9fca5] Using rspec-mocks 3.8.0
[0bc9fca5] Using rspec 3.8.0
[0bc9fca5] Using guard-rspec 4.7.3
[0bc9fca5] Bundle complete! 8 Gemfile dependencies, 60 gems now installed.
[0bc9fca5] Use `bundle info [gemname]` to see where a bundled gem is installed.
[0bc9fca5] Finished in 0.361 seconds with exit status 0 (successful)

[5f909cc8] Running git pull
[5f909cc8] Finished in 1.501 seconds with exit status 0 (successful)
[bd4866a6] 
[df36a813] Running gem bump --no-commit --no-color --version minor
[df36a813] Use `bundle info [gemname]` to see where a bundled gem is installed.
[df36a813] 
[df36a813] Bumping autowow from version 0.14.3 to 0.15.0
[df36a813] Changing version in lib/autowow/version.rb from 0.14.3 to 0.15.0
[df36a813] 
[df36a813] All is good, thanks my friend.
[df36a813] 
[df36a813] Finished in 0.332 seconds with exit status 0 (successful)

[9fc3ed9c] Running git add README.md *version.rb
[9fc3ed9c] Finished in 0.005 seconds with exit status 0 (successful)
[71231129] 
[f0d7af9b] Running git commit -m "Bumps version to v0.15.0"
[f0d7af9b] Finished in 0.006 seconds with exit status 0 (successful)
[31812bef] 
[3e576891] Running git push
[3e576891] Finished in 3.531 seconds with exit status 0 (successful)
[429b58b1] 
[475b915e] Running git checkout release
[475b915e] Finished in 0.012 seconds with exit status 0 (successful)
[76269bf8] 
[4476b6f0] Running git pull
[4476b6f0] Finished in 1.494 seconds with exit status 0 (successful)
[e7bdf7d3] 
[83f4a5e1] Running git rebase master
[83f4a5e1] Finished in 0.064 seconds with exit status 0 (successful)
[ef42234a] 
[a8dee006] Running bundle exec rake release
[a8dee006] 
[a8dee006] autowow 0.15.0 built to pkg/autowow-0.15.0.gem.
[a8dee006] Tagged v0.15.0.
[a8dee006] Pushed git commits and tags.
[a8dee006] Pushed autowow 0.15.0 to rubygems.org
[a8dee006] Finished in 9.868 seconds with exit status 0 (successful)

[d6f921b0] Running git checkout master
[d6f921b0] Finished in 0.008 seconds with exit status 0 (successful)
[be6dc2b3] 
[ef4d666d] Running git add README.md
[ef4d666d] Finished in 0.007 seconds with exit status 0 (successful)
[66f71e71] 
[81dabe48] Running git commit -m "Changes README to development version"
[81dabe48] Finished in 0.024 seconds with exit status 0 (successful)
[9687b0ee] 
[4ad3b43f] Running git push
[4ad3b43f] Finished in 5.435 seconds with exit status 0 (successful)
[75e465e8] 
[c36b853d] Running git status
[c36b853d] Pushed autowow 0.15.0 to rubygems.org
[c36b853d] On branch master
[c36b853d] Your branch is up to date with 'origin/master'.
[c36b853d] 
[c36b853d] Untracked files:
[c36b853d]   (use "git add <file>..." to include in what will be committed)
[c36b853d] 
[c36b853d]      autowow-0.14.3.gem
[c36b853d] 
[c36b853d] nothing added to commit but untracked files present (use "git add" to track)
[c36b853d] Finished in 0.016 seconds with exit status 0 (successful)
```