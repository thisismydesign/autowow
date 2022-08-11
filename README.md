# Autowow

#### Set of commands to [auto]mate [w]ay [o]f [w]orking

Status and support

- &#x2714; stable
- &#x2714; supported
- &#x2714; ongoing development

<!--- Version informartion -->
*You are viewing the README of the development version. You can find releases [here](https://github.com/thisismydesign/autowow/tags).*
<!--- Version informartion end -->

[![Gem Version](https://badge.fury.io/rb/autowow.svg)](https://badge.fury.io/rb/autowow) [![Total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/autowow?type=total)](https://rubygems.org/gems/autowow)

## Usage

`gem install autowow` or install from source via `rake install`.

Run `autowow` or `aw` to see available commands.

```
Commands:
  aw add_upstream     # adds upstream branch if available
  aw branch_merged    # clean working branch and return to default branch
  aw clear_branches   # removes unused branches
  aw exec             # runs command
  aw force_pull       # pulls branch from origin discarding local changes (including commits)
  aw help [COMMAND]   # Describe available commands or one specific command
  aw local_changes    # Are there any local changes in the repo?
  aw open             # opens project URL in browser
  aw projects         # Show projects' name, age, and whether there are local changes
  aw update_projects  # updates idle projects
```

## Development

```
docker build . -t autowow
docker run --rm -it --entrypoint sh -v $(pwd):/app autowow
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
