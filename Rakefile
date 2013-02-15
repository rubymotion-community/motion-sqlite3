# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require "bundler/gem_tasks"
require "bundler/setup"
Bundler.require :default

Motion::Project::App.setup do |app|
  app.name = 'motion-sqlite3'

  base_dir = File.dirname(__FILE__)
  app.files += Dir.glob(File.join(base_dir, "lib/motion-sqlite3/**/*.rb"))
 
  if ENV["DEFAULT_PROVISIONING_PROFILE"]
    app.provisioning_profile = ENV["DEFAULT_PROVISIONING_PROFILE"]
  end

  app.libs << "/usr/lib/libsqlite3.dylib"
  app.vendor_project('vendor/sqlite3', :static, :products => [])
end
