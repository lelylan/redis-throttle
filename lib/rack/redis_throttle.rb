require 'rack'
require 'rack/throttle'
require 'redis'
require 'hiredis'
require 'redis-namespace'

module Rack
  module RedisThrottle
    autoload :Connection, 'rack/redis_throttle/connection'
    autoload :Limiter,    'rack/redis_throttle/limiter'
    autoload :TimeWindow, 'rack/redis_throttle/time_window'
    autoload :Daily,      'rack/redis_throttle/daily'
    autoload :Interval,   'rack/redis_throttle/interval'
    autoload :VERSION,    'rack/redis_throttle/version'
  end
end
