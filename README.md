# Autowow

#### Set of commands to [auto]mate [w]ay [o]f [w]orking

Status and support

- &#x2714; stable
- &#x2714; supported
- &#x2714; ongoing development

<!--- Version informartion -->
*You are viewing the README of the development version. You can find the README of the latest release (v0.17.1) [here](https://github.com/thisismydesign/autowow/releases/tag/v0.17.1).*
<!--- Version informartion end -->

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=release)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/autowow?branch=release)   [![Gem Version](https://badge.fury.io/rb/autowow.svg)](https://badge.fury.io/rb/autowow)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/autowow?type=total)](https://rubygems.org/gems/autowow) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=master)](https://travis-ci.org/thisismydesign/autowow) [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/autowow?branch=master)   [![Bountysource](https://api.bountysource.com/badge/issue?issue_id=52798961)](https://www.bountysource.com/issues/52798961-all-changes-have-been-pushed-doesn-t-take-uncommitted-changes-into-account?utm_source=52798961&utm_medium=shield&utm_campaign=ISSUE_BADGE) |

## Disclaimer

Commands are purposefully opinionated. Use it on your own responsibility.

## Usage

Install from source as `rake install`.

Run `autowow` or `aw` to see available commands.

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

#### Force pull

`aw fp` / `autowow force_pull`

* Runs `git fetch --all`
* Runs `git reset --hard origin/<current_branch_name>`

### Gem

- Gem release
  - `aw grls`
  - `autowow gem_release`
  - [doc](doc/grls.md)

- Ruby check
  - `aw rc`
  - `autowow ruby_check`
  - [doc](doc/rc.md)

- Gem install source
  - `aw gis`
  - `autowow gem_install_local`
  - [doc](doc/gis.md)

- DB migrate reset
  - `aw dbmr`
  - `autowow db_migrate_reset`
  - [doc](doc/dbmr.md)

- Rails update project
  - `aw rup`
  - `autowow db_migrate_reset`
  - [doc](doc/dbmr.md)

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

## Contribution and feedback

This project is built around known use-cases. If you have one that isn't covered don't hesitate to open an issue and start a discussion.

Bug reports and pull requests are welcome on GitHub at https://github.com/thisismydesign/autowow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Conventions

This project follows [C-Hive guides](https://github.com/c-hive/guides) for code style, way of working and other development concerns.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
