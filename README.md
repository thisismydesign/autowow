# Autowow

#### Automates way of working.

| Branch | Status |
| ------ | ------ |
| Release | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=release)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=release)](https://coveralls.io/github/thisismydesign/autowow?branch=release)   [![Gem Version](https://badge.fury.io/rb/autowow.svg)](https://badge.fury.io/rb/autowow)   [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/autowow?type=total)](https://rubygems.org/gems/autowow) |
| Development | [![Build Status](https://travis-ci.org/thisismydesign/autowow.svg?branch=master)](https://travis-ci.org/thisismydesign/autowow)   [![Coverage Status](https://coveralls.io/repos/github/thisismydesign/autowow/badge.svg?branch=master)](https://coveralls.io/github/thisismydesign/autowow?branch=master) |

Generally commands
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

Prerequisites: no uncommitted changes on master

#### Clear branches

* Removes branches without not pushed changes 
* Keeps current and master branches

#### Add upstream

* Adds parent repository as remote 'upstream'

Prerequisites: doesn't have remote called 'upstream'

### Gem

#### Gem release

* Rebases `release` branch to master
* Releases gem via `rake release`

Prerequisites: on master

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'autowow'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install autowow

## Usage

Execute `aw` to see the manual.

## Feedback

Any feedback is much appreciated.

I can only tailor this project to fit use-cases I know about - which are usually my own ones. If you find that this might be the right direction to solve your problem too but you find that it's suboptimal or lacks features don't hesitate to contact me.

Please let me know if you make use of this project so that I can prioritize further efforts.

## Development

This gem is developed using Bundler conventions. A good overview can be found [here](http://bundler.io/v1.14/guides/creating_gem.html).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/your_gem.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
