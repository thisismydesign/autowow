# Gem install source

* `aw gis`
* `aw gem_install_source`

----

* `gem build *.gemspec`
* `gem install *.gem`

----

```
$ aw gis
[307991d0] Running gem build *.gemspec
[307991d0] WARNING:  open-ended dependency on easy_logging (>= 0.3.0) is not recommended
[307991d0]   if easy_logging is semantically versioned, use:
[307991d0]     add_runtime_dependency 'easy_logging', '~> 0.3', '>= 0.3.0'
[307991d0] WARNING:  open-ended dependency on thor (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on pastel (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on launchy (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on reflection_utils (>= 0.3.0) is not recommended
[307991d0]   if reflection_utils is semantically versioned, use:
[307991d0]     add_runtime_dependency 'reflection_utils', '~> 0.3', '>= 0.3.0'
[307991d0] WARNING:  open-ended dependency on rubocop (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on rubocop-rspec (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on gem-release (>= 0) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on guard (>= 0, development) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on guard-bundler (>= 0, development) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on guard-rspec (>= 0, development) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  open-ended dependency on coveralls (>= 0, development) is not recommended
[307991d0]   use a bounded requirement, such as '~> x.y'
[307991d0] WARNING:  See http://guides.rubygems.org/specification-reference/ for help
[307991d0]   Successfully built RubyGem
[307991d0]   Name: autowow
[307991d0]   Version: 0.15.0
[307991d0]   File: autowow-0.15.0.gem
[307991d0] Finished in 0.324 seconds with exit status 0 (successful)

[fe87e887] Running gem install *.gem
[fe87e887]   File: autowow-0.15.0.gem
[fe87e887] Successfully installed autowow-0.15.0
[fe87e887] Parsing documentation for autowow-0.15.0
[fe87e887] Done installing documentation for autowow after 0 seconds
[fe87e887] 1 gem installed
[fe87e887] Finished in 1.518 seconds with exit status 0 (successful)
```
