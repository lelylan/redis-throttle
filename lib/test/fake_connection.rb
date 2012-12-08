require 'rack'
require 'mock_redis'

# Include this class to mock the redis connection
#
#   require 'test/fake_connection'
#
module Rack
  module RedisThrottle
    class Connection

      def self.create(options={})
        @mock_redis ||= MockRedis.new
      end
    end
  end
end
