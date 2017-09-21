# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "autowow/version"

Gem::Specification.new do |spec|
  spec.name          = "autowow"
  spec.version       = Autowow::VERSION
  spec.authors       = ["Csaba Apagyi"]
  spec.email         = ["csaba.apagyi@xing.com"]

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/thisismydesign/autowow"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   << 'autowow'
  spec.executables   << 'aw'
  spec.require_paths = ["lib"]

  spec.add_dependency "easy_logging", ">= 0.3.0"
  spec.add_dependency "thor"
  spec.add_dependency "colorize"
  # Fixed version because we monkey patch it :(
  spec.add_dependency "time_difference", "= 0.5.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-rspec"
end
