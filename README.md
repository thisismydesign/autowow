# Autowow

#### Set of commands to [auto]mate [w]ay [o]f [w]orking

<!--- Version informartion -->
*You are viewing the README of the development version. You can find the README of the latest release (v0.10.0) [here](https://github.com/thisismydesign/autowow/releases/tag/v0.10.0).*
<!--- Version informartion end -->


| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=release)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/autowow?branch=release)   [![Gem Version](https://badge.fury.io/rb/autowow.svg)](https://badge.fury.io/rb/autowow)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/autowow?type=total)](https://rubygems.org/gems/autowow) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=master)](https://travis-ci.org/thisismydesign/autowow) [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/autowow?branch=master)   [![Bountysource](https://api.bountysource.com/badge/issue?issue_id=52798961)](https://www.bountysource.com/issues/52798961-all-changes-have-been-pushed-doesn-t-take-uncommitted-changes-into-account?utm_source=52798961&utm_medium=shield&utm_campaign=ISSUE_BADGE) |

## Usage

Install from source as `rake install`.

Run `autowow` or `aw` to see available commands.

*Disclaimer: Use it on your own responsibility. Some commands may be tailored to my use case but as always pull requests and issues are welcomed.*

## Commands

Commands in general
* start by outputting the status before execution
* end by outputting the status after execution
* are safe
  * only touch files via other commands (e.g. `git`)
  * do not cause conflicted state
* hard check for prerequisites
* store and restore uncommitted changes
* output executed commands that cause any change
* execute in current directory
* retain original output color

### VCS

Commands related to version control systems.
Currently only Git and the GitHub API are supported.

#### Branch merged

`aw bm` / `autowow branch_merged`

* Switches to master and pulls your merged changes
* Removes local working branch

Prerequisites: not on master

#### Update projects

`aw up` / `autowow update_projects`

* Updates local repositories
* Updates remote forks
* Searches for repositories on paths: `.`, `./*/`

Prerequisites: no uncommitted changes on master

#### Clear branches

`aw cb` / `autowow clear_branches`

* Removes branches without not pushed changes 
* Keeps current and master branches

#### Add upstream

`aw au` / `autowow add_upstream`

* Adds parent repository as remote 'upstream'

Prerequisites: doesn't have remote called 'upstream'

#### Hi

`aw hi` / `autowow hi`

Day starter routine

* Updates projects (runs 'Update projects')
* Shows latest and deprecated repos
* Shows deprecated Ruby versions

Prerequisites: in a directory that contains git repos, not in the repo itself

#### Hi!

`aw hi!` / `autowow hi!`

Day starter routine for a new start

* Runs 'Add upstream' and 'Clear branches' for all projects
* Runs 'Hi'

#### Open

`aw open` / `autowow open`

* Opens project in browser

### Gem

#### Gem release

`aw grls` / `autowow gem_release`

* Pulls chnages on `master`
* If version parameter is provided
  * Bumps version in version.rb
  * Bumps version information in README if present
* Commits and pushed changes to `master`
* Rebases `release` branch to master
* Releases gem via `rake release`
* Changes version information to development in README if present

Prerequisites: on master

#### Gem clean

`aw gc` / `autowow gem_clean`

* Removes unused gems

#### Rubocop parallel autocorrect

`aw rpa` / `autowow rubocop_parallel_autocorrect`

* Runs `rubocop` in parallel mode, autocorrects offenses on single thread

#### Bundle exec

`aw be <cmd>` / `autowow bundle_exec <cmd>`

* Runs `cmd` with `bundle exec` prefixed

### Ruby

#### Ruby versions

`aw rv` / `autowow ruby_versions`

* Shows Ruby versions in use
* Searches for repositories on paths: `.`, `./*/`

### Misc

#### Execute

`aw e` / `autowow execute`

* Executes given command

## Feedback

Any feedback is much appreciated.

I can only tailor this project to fit use-cases I know about - which are usually my own ones. If you find that this might be the right direction to solve your problem too but you find that it's suboptimal or lacks features don't hesitate to contact me.

Please let me know if you make use of this project so that I can prioritize further efforts.

## Conventions

This gem is developed using the following conventions:
- [Bundler's guide for developing a gem](http://bundler.io/v1.14/guides/creating_gem.html)
- [Better Specs](http://www.betterspecs.org/)
- [Semantic versioning](http://semver.org/)
- [RubyGems' guide on gem naming](http://guides.rubygems.org/name-your-gem/)
- [RFC memo about key words used to Indicate Requirement Levels](https://tools.ietf.org/html/rfc2119)
- [Bundler improvements](https://github.com/thisismydesign/bundler-improvements)
- [Minimal dependencies](http://www.mikeperham.com/2016/02/09/kill-your-dependencies/)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thisismydesign/autowow.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
