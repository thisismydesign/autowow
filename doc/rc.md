# Ruby check

- `aw rc`
- `autowow ruby_check`

----

* `autowow rubocop_parallel_autocorrect`
* `bundle exec rspec`

----

```
$ aw ruby_check
[fd64b225] Running bundle exec rubocop --parallel
[fd64b225] Inspecting 231 files
[fd64b225] .......................................................................................................................................................................................................................................
[fd64b225] 
[fd64b225] 231 files inspected, no offenses detected
[fd64b225] Finished in 7.559 seconds with exit status 0 (successful)

[1df429e3] Running bundle exec rspec
[1df429e3] ................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
[1df429e3] 
[1df429e3] Finished in 11.92 seconds (files took 1.7 seconds to load)
[1df429e3] 576 examples, 0 failures
[1df429e3] 
[1df429e3] Coverage report generated for RSpec to /home/csaba/workspace/autowow/coverage. 744 / 765 LOC (97.25%) covered.
[1df429e3] Finished in 14.178 seconds with exit status 0 (successful)

[2c0c4af3] Running git status
[2c0c4af3] 231 files inspected, no offenses detected
[2c0c4af3] On branch follow-ordering
[2c0c4af3] Your branch is up to date with 'origin/follow-ordering'.
[2c0c4af3] 
[2c0c4af3] nothing to commit, working tree clean
[2c0c4af3] Finished in 0.005 seconds with exit status 0 (successful)
```
