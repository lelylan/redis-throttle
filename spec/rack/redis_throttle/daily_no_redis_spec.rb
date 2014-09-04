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
            expect(last_response.status).to eq(200)
          end

          it 'returns the remaining requests header' do
            expect(last_response.headers['X-RateLimit-Remaining']).to eq('5000')
          end
        end
      end
    end
  end
end
