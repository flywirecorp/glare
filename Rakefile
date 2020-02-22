# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run only unit tests'
RSpec::Core::RakeTask.new('spec:unit') do |task|
  task.rspec_opts = '--tag ~integration'
end

desc 'Run only integration tests'
RSpec::Core::RakeTask.new('spec:integration') do |task|
  task.rspec_opts = '--tag integration'
end

task(default: :spec)
