# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-sqlite3/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Green"]
  gem.email         = ["mattgreenrocks@gmail.com"]
  gem.description   = "A minimal wrapper over the SQLite 3 C API for RubyMotion"
  gem.summary       = "A minimal wrapper over the SQLite 3 C API for RubyMotion"
  gem.homepage      = "http://github.com/mattgreen/motion-sqlite3"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "motion-sqlite3"
  gem.require_paths = ["lib"]
  gem.version       = SQLite3::VERSION

  gem.add_development_dependency 'rake', '>= 0.9.0'
  gem.add_development_dependency 'guard-motion', '~> 0.1.1'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.1'
end
