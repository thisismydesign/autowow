# Autowow

#### Set of commands to AUTOmate Way Of Working

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=release)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/autowow?branch=release)   [![Gem Version](https://badge.fury.io/rb/autowow.svg)](https://badge.fury.io/rb/autowow)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/autowow?type=total)](https://rubygems.org/gems/autowow) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=master)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/autowow?branch=master) |

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

### VCS

Commands related to version control systems.
Currently only Git and the GitHub API are supported.

#### Branch merged

* Switches to master and pulls your merged changes
* Removes local working branch

Prerequisites: not on master

#### Update projects

* Updates local repositories
* Updates remote forks
* Searches for repositories on paths: `.`, `./*/`

Prerequisites: no uncommitted changes on master

#### Clear branches

* Removes branches without not pushed changes 
* Keeps current and master branches

#### Add upstream

* Adds parent repository as remote 'upstream'

Prerequisites: doesn't have remote called 'upstream'

#### Hi

Day starter routine

* Updates projects (runs 'Update projects')
* Shows latest and deprecated repos

#### Hi!

Day starter routine for a new start

* Runs 'Add upstream' and 'Clear branches' for all projects
* Runs 'Hi'

#### Open

* Opens project in browser

### Gem

#### Gem release

* Rebases `release` branch to master
* Releases gem via `rake release`

Prerequisites: on master

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/your_gem.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
