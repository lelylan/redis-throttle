require 'rack'

module Rack
  module RedisThrottle
    class Connection

      def self.create(options={})
        options[:url] = redis_provider || 'redis://localhost:6379/0' unless options.has_key?(:url)
        method = Redis::VERSION.to_i >= 3 ? :new : :connect
        client = Redis.send(method, url: options[:url], driver: :hiredis)
        Redis::Namespace.new("redis-throttle:#{ENV['RACK_ENV']}:rate", redis: client)
      end

      private

      def self.redis_provider
        ENV['REDIS_RATE_LIMIT_URL']
      end
    end
  end
end
