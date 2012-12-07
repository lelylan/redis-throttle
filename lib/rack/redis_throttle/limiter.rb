require 'rack'

module Rack
  module RedisThrottle
    class Limiter < ::Rack::Throttle::Limiter
    end
  end
end
