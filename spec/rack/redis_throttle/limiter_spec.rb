require 'spec_helper'

describe Rack::RedisThrottle::Limiter do

  describe 'test' do
    it 'test' do
      get '/'
      puts last_response.body
      pp last_response.status
      pp last_response.headers
    end
  end
end
