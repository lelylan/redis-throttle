module Rack
  module RedisThrottle
    class Interval < Limiter

      # Returns `true` if sufficient time has passed since the last request.
      def allowed?(request)
        t1 = request_start_time(request)
        t0 = cache_get(key = cache_key(request)) rescue nil
        allowed = !t0 || (dt = t1 - t0.to_f) >= minimum_interval
        begin
          cache_set(key, t1)
          allowed
        rescue => e
          # If an error occurred while trying to update the timestamp stored
          # in the cache, we will fall back to allowing the request through.
          # This prevents the Rack application blowing up merely due to a
          # backend cache server (Memcached, Redis, etc.) being offline.
          allowed = true
        end
      end

      def retry_after
        minimum_interval
      end

      def minimum_interval
        @min ||= (@options[:min] || 1.0).to_f
      end
    end
  end
end
