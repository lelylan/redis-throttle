require 'spec_helper'

def app
  @target_app = example_target_app
  @cache = Rack::RedisThrottle::Connection.create(url: 'redis://localhost:9999/0')
  @daily_no_redis_app ||= Rack::RedisThrottle::Daily.new(@target_app, max: 5000, cache: @cache)
end

describe Rack::RedisThrottle::Daily do

  let(:cache) { Rack::RedisThrottle::Connection.create(url: 'redis://localhost:9999/0') }
  before      { app.options[:cache] = cache }

  let(:time_key)   { Time.now.utc.strftime('%Y-%m-%d') }
  let(:client_key) { '127.0.0.1' }
  let(:cache_key)  { "#{client_key}:#{time_key}" }

  describe 'when makes a request' do

    describe 'with the Authorization header' do

      describe 'when the rate limit is not reached' do

        before { get '/foo', {}, 'AUTHORIZATION' => 'Bearer <token>' }

        it 'returns a 200 status' do
          last_response.status.should == 200
        end

        it 'returns the remaining requests header' do
          last_response.headers['X-RateLimit-Remaining'].should == '4999'
        end

        it 'does not decrease the available requests' do
          previous = last_response.headers['X-RateLimit-Remaining'].to_i
          get '/', {}, 'AUTHORIZATION' => 'Bearer <token>'
          previous.should == last_response.headers['X-RateLimit-Remaining'].to_i
        end
      end
    end

    describe 'with no Authorization header' do

      before { get '/foo' }

      it 'returns a 200 status' do
        last_response.status.should == 200
      end

      it 'does not return the requests limit headers' do
        last_response.headers['X-RateLimit-Limit'].should be_nil
      end

      it 'does not return remaining requests header' do
        last_response.headers['X-RateLimit-Remaining'].should be_nil
      end
    end
  end
end

