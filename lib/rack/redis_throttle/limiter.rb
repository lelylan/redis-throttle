require 'rack'

module Rack
  module RedisThrottle
    class Limiter < Rack::Throttle::Limiter

      def initialize(app, options = {})
        options.reverse_merge!({ cache: Rack::RedisThrottle::Connection.create })
        @app, @options = app, options
      end

      def call(env)
        request = Rack::Request.new(env)
        if allowed?(request)
          status, headers, body = app.call(env)
          headers = rate_limit_headers(request, headers) if need_protection?(request)
          [status, headers, body]
        else
          rate_limit_exceeded
        end
      end

      # used to define the cache key
      def client_identifier(request)
        request.ip.to_s
      end

      def rate_limit_exceeded
        headers = respond_to?(:retry_after) ? {'Retry-After' => retry_after.to_f.ceil.to_s} : {}
        http_error(options[:code] || 403, options[:message] || 'Rate Limit Exceeded', headers)
      end

      def http_error(code, message = nil, headers = {})
        [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers),
          [ http_status(code) + (message.nil? ? "\n" : " (#{message})\n")]]
      end
    end

    class Connection

      def self.create(options={})
        url    = redis_provider || 'redis://localhost:6379/0'
        client = Redis.connect(url: url, driver: :hiredis)
        Redis::Namespace.new("lelylan:#{ENV['RACK_ENV']}:rate", redis: client)
      end

      private

      def self.redis_provider
        ENV['RATE_REDIS_URL']
      end
    end
  end
end
