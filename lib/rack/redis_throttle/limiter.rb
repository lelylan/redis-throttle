require 'rack'

module Rack
  module RedisThrottle
    class Limiter < Rack::Throttle::Limiter

      def initialize(app)
        options = { cache: Rack::RedisThrottle::Connection.create }
        @app, @options = app, options
      end

      # Set the rate limit headers
      def call(env)
        status, headers, body = app.call(env)
        request = Rack::Request.new(env)
        if need_defense?(request)
          headers['X-RateLimit-Limit']     = max_per_window.to_s
          headers['X-RateLimit-Remaining'] = ([0, max_per_window - (cache_get(cache_key(request)).to_i rescue 1)].max).to_s
        end
        [status, headers, body]
      end

      # Infinite rate limit for public requests
      # Limited rate limit for private requests
      def allowed?(request)
        case
          when whitelisted?(request) then true
          when blacklisted?(request) then false
          else request.env.has_key?('AUTHORIZATION') ? cache_incr(request) <= max_per_window : true
        end
      end

      # Increase the redis key associated to the user
      def cache_incr(request)
        key   = cache_key(request)
        count = cache.incr(key)
        cache.expire(key, expiring_time) if count == 1
        count
      end

      # Use the user id as client identifier
      def client_identifier(request)
        request.env.key['AUTHORIZATION']
      end

      # The key always expires at midnight UTC time
      def expiring_time
        Time.now.utc.tomorrow.midnight - Time.now.utc
      end
    end

    class Connection

      def self.create(options={})
        url    = redis_provider || 'redis://localhost:6379/0'
        client = Redis.connect(url: url, driver: :hiredis)
        Redis::Namespace.new("lelylan:#{Rails.env}:rate", redis: client)
      end

      private

      def self.redis_provider
        ENV[ENV['RATE_REDIS_URL']]
      end
    end
  end
end
