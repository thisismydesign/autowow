require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "logger"
@logger = Logger.new(STDOUT)

RSpec::Core::RakeTask.new(:spec)

desc "Check if source can be required and is correctly required"
task :require do
  dir = File.dirname(__FILE__)
  gemspec = load_gemspec(dir)

  # Order is important, assert_can_be_required should be run first
  assert_can_be_required(dir, gemspec)
  check_source_files_required(dir, gemspec)
  check_source_files_included(dir, gemspec)
end

def load_gemspec(dir)
  require "bundler/setup"
  Gem::Specification.find do |spec|
    spec.full_gem_path.include?(File.dirname(__FILE__))
  end
end

def check_source_files_required(dir, gemspec)
  require_gem(gemspec)
  ruby_files = Dir.glob("#{dir}/**/*.rb").reject{ |f| f.include?('/spec/') }
  required_ruby_files = $LOADED_FEATURES.select { |f| f.include?(dir) }
  (ruby_files - required_ruby_files).each do |file|
    @logger.warn("Source file not required when loading gem: #{file.sub("#{dir}/", '')}")
  end
end

def check_source_files_included(dir, gemspec)
  ruby_files_relative = Dir.glob("#{dir}/**/*.rb").reject { |f| f.include?('/spec/') }.map { |f| f.sub("#{dir}/", '') }
  (ruby_files_relative - gemspec.files.select { |f| f.end_with?('.rb') }).each do |file|
    @logger.warn("File ignored when building gem because it's not added to git: #{file}")
  end
end

def assert_can_be_required(dir, gemspec)
  local_load_paths = $LOAD_PATH.select { |path| path.include?(dir) }
  $LOAD_PATH.reject! { |path| local_load_paths.include?(path) }
  begin
    require_gem(gemspec)
  rescue LoadError => e
    @logger.error("Gem source cannot be required relatively: #{e}")
    raise
  ensure
    $LOAD_PATH.push(*local_load_paths)
  end
end

def require_gem(gemspec)
  require_relative "lib/#{gemspec.name.gsub('-', '/')}"
end

task :default => [:spec]
