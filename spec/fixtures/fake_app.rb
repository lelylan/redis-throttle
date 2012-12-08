require 'rubygems'
require 'sinatra'
require 'rack/redis_throttle'

module Rack
  module Test
    class FakeApp < Sinatra::Base

      get '/foo' do
        'Hello Redis Throttler!'
      end
    end
  end
end
