# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
$:.unshift("~/.rubymotion/rubymotion-templates")

require "motion/project/template/ios"
require "motion/project/template/gem/gem_tasks"
require "bundler/setup"
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'motion-sqlite3'

  if ENV["DEFAULT_PROVISIONING_PROFILE"]
    app.provisioning_profile = ENV["DEFAULT_PROVISIONING_PROFILE"]
  end
end
