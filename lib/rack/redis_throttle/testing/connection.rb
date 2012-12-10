require 'rack'
require 'mock_redis'

module Rack
  module RedisThrottle
    class Connection

      def self.create(options={})
       MockRedis.new
      end
    end
  end
end
