require 'spec_helper'
require 'test/connection'

describe Rack::RedisThrottle::Daily do

  let(:cache)      { Rack::RedisThrottle::Connection.create }

  let(:time_key)   { Time.now.utc.strftime('%Y-%m-%d') }
  let(:client_key) { '127.0.0.1' }
  let(:cache_key)  { "#{client_key}:#{time_key}" }

  before { cache.set cache_key, 100 }

  # get set incr call
  #before { cache.stub(:get).and_return(Exception.new) }
  #before { cache.stub(:set).and_return(Exception.new) }
  before { cache.stub(:incr).and_raise(Redis::BaseConnectionError.new) }
  #before { cache.stub(:call).and_return(Exception.new) }

  describe 'when makes a request' do

    describe 'with the Authorization header' do

      describe 'when the rate limit is not reached' do

        before { get '/', {}, 'AUTHORIZATION' => 'Bearer <token>' }

        it 'returns a 200 status' do
          last_response.status.should == 200
        end
      end
    end
  end
end

