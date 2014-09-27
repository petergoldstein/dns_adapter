# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dns_adapter/version'

Gem::Specification.new do |spec|
  spec.name          = 'dns_adapter'
  spec.version       = DNSAdapter::VERSION
  spec.authors       = ['Peter M. Goldstein']
  spec.email         = ['peter.m.goldstein@gmail.com']
  spec.summary       = 'An adapter layer for DNS queries.'
  spec.description   = 'An adapter layer for DNS queries.'
  spec.homepage      = 'https://github.com/petergoldstein/dns_adapter'
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop'
end
