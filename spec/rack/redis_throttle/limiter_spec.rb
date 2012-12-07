require 'spec_helper'

describe Rack::RedisThrottle::Limiter do

  describe 'test' do
    it 'test' do
      get '/'
      pp last_response
      puts last_response.body
    end
  end
end
