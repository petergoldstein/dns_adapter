require 'simplecov'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start || SimpleCov.start

require 'dns_adapter'

# Support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
