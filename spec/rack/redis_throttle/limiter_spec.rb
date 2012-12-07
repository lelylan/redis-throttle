require 'spec_helper'

describe Rack::RedisThrottle::Limiter do

  describe 'test' do
    it 'test' do
      get '/'
      pp last_request
    end
  end
end
