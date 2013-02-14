# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'rubygems'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-sqlite3'

  base_dir = File.dirname(__FILE__)
  app.files += Dir.glob(File.join(base_dir, "lib/motion-sqlite3/**/*.rb"))
 
  if ENV["DEFAULT_PROVISIONING_PROFILE"]
    app.provisioning_profile = ENV["DEFAULT_PROVISIONING_PROFILE"]
  end

  app.libs << "/usr/lib/libsqlite3.dylib"
  app.vendor_project('vendor/sqlite3', :static, :products => [])
end
