require 'rack'
require 'rack/throttle'
require 'redis'
require 'hiredis'
require 'redis-namespace'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/date/calculations'

module Rack
  module RedisThrottle
    autoload :Limiter,    'rack/redis_throttle/limiter'
    autoload :TimeWindow, 'rack/redis_throttle/time_window'
    autoload :Daily,      'rack/redis_throttle/daily'
    autoload :VERSION,    'rack/redis_throttle/version'
  end
end
