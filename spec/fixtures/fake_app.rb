require 'rubygems'
require 'sinatra/base'

module Rack
  module Test
    class FakeApp < Sinatra::Base

      get '/' do
        "Hello, GET: #{params.inspect}"
      end

    end
  end
end
