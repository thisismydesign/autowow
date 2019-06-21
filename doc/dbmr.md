# Gem install source

* `aw dbmr`
* `autowow db_migrate_reset`

----

* `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset`

----

```
$ aw dbmr
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
```
