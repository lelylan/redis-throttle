# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rack/redis_throttle/version'

Gem::Specification.new do |gem|
  gem.version     = '0.0.1'
  gem.name        = 'redis-throttle'
  gem.homepage    = 'https://github.com/lelylan'
  gem.summary     = 'HTTP request rate limiter for Rack applications with Redigem.'
  gem.description = 'Rack middleware for rate-limiting incoming HTTP requests with Redigem.'

  gem.authors = ['Andrea Reginato']
  gem.email   = ['andrea.reginato@gmail.com']

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.rubyforge_project    = 'redis-throttle'
  gem.post_install_message = nil

  gem.add_dependency 'rack'
  gem.add_dependency 'rack-throttle'
  gem.add_dependency 'redis'
  gem.add_dependency 'hiredis'
  gem.add_dependency 'redis-namespace'
  gem.add_dependency 'activesupport'

  gem.test_files = [
    'spec/fixtures/fake_app.rb',
    'spec/spec_helper.rb',
    'spec/support/matchers/body.rb',
  ]

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sinatra'
  gem.add_development_dependency 'foreman'
  gem.add_development_dependency 'timecop'
  gem.add_development_dependency 'mock_redis'
  gem.add_development_dependency 'hashie'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rb-fsevent' if RUBY_PLATFORM =~ /darwin/i
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'fuubar'
  gem.add_development_dependency 'growl'
  gem.add_development_dependency 'debugger'
end
