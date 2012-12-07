require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/test'
require 'rspec'

require File.dirname(__FILE__) + '/fixtures/fake_app'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods

  def app
    Rack::Lint.new(Rack::Test::FakeApp.new)
  end
end
