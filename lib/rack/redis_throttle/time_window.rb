module Rack
  module RedisThrottle
    class TimeWindow < Limiter

      # Check my rate limit
      def allowed?(request)
        case
        when whitelisted?(request) then true
        when blacklisted?(request) then false
        else need_protection?(request) ? cache_incr(request) <= max_per_window(request) : true
        end
      end

      def need_protection?(request)
        true
      end

      def rate_limit_headers(request, headers)
        headers['X-RateLimit-Limit']     = max_per_window(request).to_s
        headers['X-RateLimit-Remaining'] = ([0, max_per_window(request) - (cache_get(cache_key(request)).to_i rescue 1)].max).to_s
        headers
      end
    end
  end
end
