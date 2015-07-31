# encoding: UTF-8
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:style)

task default: %w(style spec)
