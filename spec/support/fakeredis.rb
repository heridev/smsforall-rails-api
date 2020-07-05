require 'fakeredis/rspec'

module ReadCache
  class << self
    def redis
      @redis ||= Redis.new
    end
  end
end
