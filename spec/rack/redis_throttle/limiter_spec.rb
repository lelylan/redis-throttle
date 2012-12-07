#puts last_response.body

require 'spec_helper'

describe Rack::RedisThrottle::Limiter do

  let(:cache)    { Rack::RedisThrottle::Connection.create }
  let(:time_key) { Time.now.utc.strftime('%Y-%m-%d') }
  let(:key)      { "127.0.0.1:#{time_key}" }
  before         { cache.set key, 1 }

  describe 'when makes a request' do

    describe 'with the Authorization header' do

      describe 'when the rate limit is not reached' do

        before { get '/', {}, 'AUTHORIZATION' => 'Bearer token' }

        it 'returns a 200 status' do
          last_response.status.should == 200
        end

        it 'returns the requests limit headers' do
          last_response.headers['X-RateLimit-Limit'].should_not be_nil
        end

        it 'returns the remaining requests header' do
          last_response.headers['X-RateLimit-Remaining'].should_not be_nil
        end

        it 'decreases the available requests' do
          previous = last_response.headers['X-RateLimit-Remaining'].to_i
          get '/', {}, 'AUTHORIZATION' => 'Bearer token'
          previous.should == last_response.headers['X-RateLimit-Remaining'].to_i + 1
        end
      end

      describe 'when reaches the rate limit' do

        before { cache.set key, 5000 }
        before { get '/', {}, 'AUTHORIZATION' => 'Bearer token' }

        it 'returns a 403 status' do
          last_response.status.should == 403
        end

        it 'returns a rate limited exceeded body' do
          last_response.body.should == '403 Forbidden (Rate Limit Exceeded)'
        end

        after  { cache.set key, 1 }
      end
    end

    describe 'with no Authorization header' do

      before { get '/' }

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
