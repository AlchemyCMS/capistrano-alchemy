# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/alchemy/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-alchemy"
  spec.version       = Capistrano::Alchemy::VERSION
  spec.authors       = ["Martin Meyerhoff", "Thomas von Deyen"]
  spec.email         = ["mamhoff@googlemail.com", "thomas@vondeyen.com"]
  spec.summary       = %q{Capistrano Tasks for AlchemyCMS.}
  spec.homepage      = "https://alchemy-cms.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano-rails", "~> 1.1"

  spec.add_development_dependency 'rspec'
end
