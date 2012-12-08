require 'rack'

module Rack
  module RedisThrottle
    class Daily < TimeWindow

      def max_per_day(request)
        @max_per_day ||=  options[:max_per_day] || options[:max] || 86400
      end

      alias_method :max_per_window, :max_per_day

      protected

      def cache_key(request)
        [super, Time.now.utc.strftime('%Y-%m-%d')].join(':')
      end
    end
  end
end
