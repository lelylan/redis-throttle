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
          rate_limit_exceeded(request)
        end
      end

      def cache
        begin
          case cache = (options[:cache] ||= {})
          when Proc then cache.call
          else cache
          end
        rescue => e
          puts "ERROR: Redis connection not available. Rescuing cache.call" if ENV['DEBUG']
          return {}
        end
      end

      def cache_has?(key)
        cache.get(key) rescue false
      end

      def cache_get(key, default = nil)
        begin
          cache.get(key) || default
        rescue Redis::BaseConnectionError => e
          puts "ERROR: Redis connection not available. Rescuing cache.get(key)" if ENV['DEBUG']
          return 0
        end
      end

      def cache_set(key, value)
        cache.set(key, value) rescue 0
      end

      def cache_incr(request)
        begin
          key   = cache_key(request)
          count = cache.incr(key)
          cache.expire(key, 1.day) if count == 1
          count
        rescue Redis::BaseConnectionError => e
          puts "ERROR: Redis connection not available. Rescuing cache.incr(key)" if ENV['DEBUG']
          return 0
        end
      end

      def cache_key(request)
        id = client_identifier(request)
        case
        when options.has_key?(:key)
          options[:key].call(request)
        when options.has_key?(:key_prefix)
          [options[:key_prefix], id].join(':')
        else id
        end
      end

      # used to define the cache key
      def client_identifier(request)
        request.ip.to_s
      end

      def rate_limit_exceeded(request)
        headers = respond_to?(:retry_after) ? {'Retry-After' => retry_after.to_f.ceil.to_s} : {}
        http_error(request, options[:code] || 403, options[:message] || 'Rate Limit Exceeded', headers)
      end

      def http_error(request, code, message = nil, headers = {})
        [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers),
          [ http_status(code) + (message.nil? ? "\n" : " (#{message})")]]
      end
    end
  end
end
