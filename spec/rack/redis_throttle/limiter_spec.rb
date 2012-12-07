#puts last_response.body

require 'spec_helper'

describe Rack::RedisThrottle::Limiter do

  let(:cache) { Rack::RedisThrottle::Connection.create }
  let(:key)   { '127.0.0.1:2012-12-07' }
  before      { cache.set key, 1 }

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

        it 'returna a 403 status' do
          last_response.status.should == 403
        end

        after  { cache.set key, 1 }
      end
    end

    describe 'when the Authorization header is not present'
  end
end
