# frozen_string_literal: true

module ReadCache
  class << self
    def redis
      @redis ||= Redis.new(url: Rails.application.credentials[:redis_url])
    end
  end
end
