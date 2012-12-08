require 'rack'
require 'mock_redis'

module Rack
  module RedisThrottle
    class Connection
      def self.create
        MockRedis.new
      end
    end
  end
end
