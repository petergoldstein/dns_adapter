require 'bundler/gem_tasks'

task default: :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color', '--format doc']
end

require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
  # don't abort rake on failure
  task.fail_on_error = false
end
