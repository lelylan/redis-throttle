require 'rack'
require 'mock_redis'

# Include this class to mock the redis connection
#
#   require 'test/no_connection'
#
module Rack
  module RedisThrottle
    class Connection
      def self.create(options={})
        Redis.connect(url: 'redis://localhost:9999/0', driver: :hiredis)
      end
    end
  end
end
