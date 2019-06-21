# Ruby check

- `aw rc`
- `autowow ruby_check`

----

* `autowow rubocop_parallel_autocorrect`
* `bundle exec rspec`
* `autowow db_migrate_reset`
* `bundle exec rake db:seed`

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

[4b0d49ad] Running DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset
[4b0d49ad] Dropped database 'dev'
[4b0d49ad] Dropped database 'test'
[4b0d49ad] Created database 'dev'
[4b0d49ad] Created database 'test'
[4b0d49ad] == 20190201144442 CreateUser: migrating =======================================
[4b0d49ad] -- create_table(:users, {})
[4b0d49ad]    -> 0.0136s
[4b0d49ad] == 20190201144442 CreateUser: migrated (0.0138s) ==============================
[4b0d49ad]
[4b0d49ad] Model files unchanged.
[4b0d49ad] Finished in 1.726 seconds with exit status 0 (successful)

[26db2b86] Running bundle exec rake db:seed
[26db2b86] Model files unchanged.
[26db2b86] Finished in 9.334 seconds with exit status 0 (successful)

[2c0c4af3] Running git status
[2c0c4af3] 231 files inspected, no offenses detected
[2c0c4af3] On branch master
[2c0c4af3] Your branch is up to date with 'origin/master'.
[2c0c4af3] 
[2c0c4af3] nothing to commit, working tree clean
[2c0c4af3] Finished in 0.005 seconds with exit status 0 (successful)
```
