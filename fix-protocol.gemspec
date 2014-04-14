# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'fix/protocol/version'

Gem::Specification.new do |s|
  s.name        = 'fix-protocol'
  s.version     = Fix::Protocol::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['David François']
  s.email       = ['david.francois@paymium.com']
  s.homepage    = 'https://github.com/paymium/fix-protocol'
  s.summary     = 'FIX message classes, parsing and generation'
  s.description = s.summary

  s.required_rubygems_version = '>= 1.3.6'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'simplecov'

  s.add_dependency 'treetop'
  s.add_dependency 'polyglot'

  s.files        = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  s.require_path = 'lib'
end
