require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/test'
require 'mock_redis'
require 'rspec'
require 'timecop'
require 'active_support/core_ext/time/calculations'

require File.dirname(__FILE__) + '/fixtures/fake_app'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods
end

def app
  @target_app ||= Rack::Lint.new(Rack::Test::FakeApp.new)
  @daily_app  ||= Rack::RedisThrottle::Daily.new(@target_app)
end
