# frozen_string_literal: true

module ReadCache
  class << self
    def redis
      @redis ||= Redis.new(url: ENV.fetch('REDIS_URL'))
    end
  end
end
