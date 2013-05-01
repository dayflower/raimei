require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Run spec tests'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern    = './spec/*_spec.rb'
  t.rspec_opts = %w(-fs --color)
end
