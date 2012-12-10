# Redis Throttle Middleware

This is fork of the [Rack Throttle](http://github.com/datagraph/rack-throttle) middleware
that provides logic for rate-limiting incoming HTTP requests to Rack applications using
Redis as storage system. You can use `Rack::RedisThrottle` with any Ruby web framework based
on Rack, including Ruby on Rails 3.0 and Sinatra. This gem was designed to experiment rate 
limit with Rails 3.x and [Doorkeeper](https://github.com/applicake/doorkeeper/).

## Features

* Works only with Redis.
* Automatically deploy by setting `ENV['REDIS_RATE_LIMIT_URL']`.
* When the Redis connection is not available redis throttle skips the rate limit check (it does not blow up).
* Automatically adds `X-RateLimit-Limit` and `X-RateLimit-Remaining` headers.


## Requirements

Devices API is tested against MRI 1.9.3.


## Installation

Update your gem file and run `bundle`

    gem 'redis-throttle', git: 'git@github.com:andreareginato/redis-throttle.git'


## Rails Examples

### Limit the daily numebr of requests to 2500

   use Rack::RedisThrottle::Daily, max: 2500

### Limit the hourly numebr of requests to 500

   use Rack::RedisThrottle::Hourly, max: 500

### Enforcing a minimum 1-second interval between requests

   use Rack::RedisThrottle::Interval, min: 1

### Combining various throttling constraints into one overall policy

   use Rack::RedisThrottle::Daily, max: 2500
   use Rack::RedisThrottle::Hourly, max: 500
   use Rack::RedisThrottle::Interval, min: 1


## Customizations

You can fully customize the implementation details of any of these strategies
by simply subclassing one of the default implementations. Follows an example where:

* we suppose you are using Doorkeper as authorization system (OAuth2)
* the number of daily requests are based on the user id and not the IP
  address (default in `Rack::RedisThrottle`)
* the number of daily requests is dynamically set per user by the
  `user#rate_limit` field.

    require 'rack/redis_throttle'

    class DailyRateLimit < Rack::RedisThrottle::Daily

      def call(env)
        @user_rate_limit = nil
        super
      end

      # Identify the client through the user id
      def client_identifier(request)
        user_rate_limit(request).id
      end

      # Set the max number of requests based on the user#rate_limit field
      def max_per_window(request)
        user_rate_limit(request).rate_limit
      end

      # Rate limit only requests sending the access token
      def need_protection?(request)
        request.env.has_key?('HTTP_AUTHORIZATION')
      end

      private

      # Extract the user object through the access token and cache it
      def user_rate_limit(request)
        @user_rate_limit ||= find_user_rate_limit(request)
      end

      def user_rate_limit(request)
        token         = request.env['HTTP_AUTHORIZATION'].split(' ')[-1]
        access_token  = Doorkeeper::AccessToken.where(token: token).first
        access_token ? User.find(access_token.resource_owner_id) : nil
      end
    end


## Rate limit headers

`Rack::RedisThrottle` automatically sets two rate limits headers to let the 
client know the max number of requests and the one availables.

    HTTP/1.1 200 OK
    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 4999

When you exceed the API calls limit your request is forbidden.

    HTTP/1.1 403 Forbidden
    X-RateLimit-Limit: 5000
    X-RateLimit-Remaining: 0


## HTTP client identification

The rate-limiting counters stored and maintained by `Rack::RedisThrottle` are
keyed to unique HTTP clients. By default, HTTP clients are uniquely identified
by their IP address as returned by `Rack::Request#ip`. If you wish to instead
use a more granular, application-specific identifier such as a session key or
a user account name, you need only subclass a throttling strategy implementation
and override the `#client_identifier` method.


## HTTP Response Codes and Headers

When a client exceeds their rate limit, `Rack::Throttle` by default returns
a "403 Forbidden" response with an associated "Rate Limit Exceeded" message
in the response body. If you need personalize it, for example with a
JSON message.


    def http_error(request, code, message = nil, headers = {})
      [ code, { 'Content-Type' => 'application/json' }.merge(headers), [body(request).to_json] ]
    end

    def body(request)
      {
        status: 403,
        method: request.env['REQUEST_METHOD'],
        request: "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{request.env['PATH_INFO']}",
        description: 'Rate limit exceeded',
        daily_rate_limit: max_per_window(request)
      }
    end


## Notes

### Testing coverage

Only `Rack::RedisThrottle::Daily` has a test suite. We will cover all
the gem whenever I'll find more time and I'll see it being used widely.


## Contributing

Fork the repo on github and send a pull requests with topic branches. Do not forget to
provide specs to your contribution.


### Running specs

* Fork and clone the repository.
* Run `gem install bundler` to get the latest for the gemset.
* Run `bundle install` for dependencies.
* Run `bundle exec guard` and press enter to execute all specs.


## Spec guidelines

Follow [betterspecs.org](http://betterspecs.org) guidelines.


## Coding guidelines

Follow [github](https://github.com/styleguide/) guidelines.


## Feedback

Use the [issue tracker](https://github.com/andreareginato/redis-throttle/issues) for bugs.
[Mail](mailto:andrea.reginato@gmail.com) or [Tweet](http://twitter.com/andreareginato)
us for any idea that can improve the project.


## Links

* [GIT Repository](https://github.com/andreareginato/redis-throttle)


## Authors

[Andrea Reginato](http://twitter.com/andreareginato)
Thanks to [Lelylan](http://lelylan.com) for letting me share the code.


## Contributors

Special thanks to the following people for submitting patches.


## Changelog

See [CHANGELOG](devices/blob/master/CHANGELOG.md)


## Copyright

`Rack::RedisThrottle` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying LICENSE file.

