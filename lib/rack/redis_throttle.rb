require 'rack'
require 'rack/throttle'

module Rack
  module RedisThrottle
    autoload :Limiter,    'rack/redis_throttle/limiter'
    #autoload :Interval,   'rack/redis_throttle/interval'
    #autoload :Daily,      'rack/redis_throttle/daily'
    #autoload :Hourly,     'rack/redis_throttle/hourly'
    autoload :VERSION,    'rack/redis_throttle/version'
  end
end
