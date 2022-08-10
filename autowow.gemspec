# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "autowow/version"

Gem::Specification.new do |spec|
  spec.name          = "autowow"
  spec.version       = Autowow::VERSION
  spec.authors       = ["thisismydesign"]
  spec.email         = ["thisismydesign@users.noreply.github.com"]

  spec.summary       = %q{Set of commands to AUTOmate Way Of Working}
  spec.homepage      = "https://github.com/thisismydesign/autowow"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   << 'autowow'
  spec.executables   << 'aw'
  spec.require_paths = ["lib"]

  spec.add_dependency "easy_logging", ">= 0.3.0"        # Include logger easily, without redundancy
  spec.add_dependency "thor"                            # CLI
  spec.add_dependency "pastel"                          # Colorize output of own logger
  spec.add_dependency "time_difference", "= 0.5.0"      # Calculate project age. Fixed version because of refinements :(
  spec.add_dependency "launchy"                         # Open project in browser
  spec.add_dependency "tty-command", "~> 0.8"           # Execute system commands nicely
  spec.add_dependency "reflection_utils", ">= 0.3.0"    # Invoke module methods without including the module
  spec.add_dependency "rubocop"                         # Style check
  spec.add_dependency "rubocop-rspec"                   # Style check

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
end
