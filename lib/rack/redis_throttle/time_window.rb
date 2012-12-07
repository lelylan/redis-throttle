module Rack
  module RedisThrottle
    class TimeWindow < Limiter

      # Check my rate limit
      def allowed?(request)
        case
        when whitelisted?(request) then true
        when blacklisted?(request) then false
        else cache_incr(request) <= max_per_window(request)
        end
      end

      # No rate limit for public requests
      def need_protection?(request)
        request.env.has_key?('AUTHORIZATION')
      end

      def rate_limit_headers(request, headers)
        headers['X-RateLimit-Limit']     = max_per_window(request).to_s
        headers['X-RateLimit-Remaining'] = ([0, max_per_window(request) - (cache_get(cache_key(request)).to_i rescue 1)].max).to_s
        headers
      end

      # Increase the redis key associated to the user
      def cache_incr(request)
        key   = cache_key(request)
        count = cache.incr(key)
        cache.expire(key, expiring_time) if count == 1
        count
      end

      # The key always expires at midnight UTC time
      def expiring_time
        Time.now.utc.tomorrow.midnight - Time.now.utc
      end
    end
  end
end
