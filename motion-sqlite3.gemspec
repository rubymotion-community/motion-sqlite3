# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-sqlite3/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Green"]
  gem.email         = ["mattgreenrocks@gmail.com"]
  gem.description   = ""
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "elevate"
  gem.require_paths = ["lib"]
  gem.version       = SQLite3::VERSION

  gem.add_development_dependency 'rake', '>= 0.9.0'
  gem.add_development_dependency 'guard-motion', '~> 0.1.1'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.1'
end
