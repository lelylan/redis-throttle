require 'spec_helper'


describe Rack::RedisThrottle::Daily do

  describe 'when the redis connection is missing' do

    # middleware settings
    let(:cache) { Rack::RedisThrottle::Connection.create(url: 'redis://localhost:9999/0') }
    before      { app.options[:max]   = 5000 }
    before      { app.options[:cache] = cache }


    describe 'when makes a request' do

      describe 'with the Authorization header' do

        describe 'when the rate limit is not reached' do

          before { get '/foo' }

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
    end
  end
end
