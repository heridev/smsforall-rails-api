# frozen_string_literal: true

require 'active_support/security_utils'
require 'sidekiq'
require 'sidekiq/web'

unless Rails.env.test?

  max_work_threads = Integer(ENV['MAX_WORK_THREADS_RUFUS'] || 1)
  SidekiqScheduler::Scheduler.instance.rufus_scheduler_options = {
    max_work_threads: max_work_threads
  }

  Sidekiq.configure_client do |config|
    # As a rule of thumb, the Sidekiq client, which is usually a
    # rails app will only need 1 connection to redis. I used 2
    # in the config above to handle rare cases where one of
    # the connection hangs and at least the client has a backup to use.
    redis_client_size = Integer(ENV['REDIS_CLIENT_SIZE'] || 2)
    config.redis = {
      url: ENV['REDIS_URL'],
      size: redis_client_size,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  end

  Sidekiq.configure_server do |config|
    # 10 for free tier and 50 connections for micro as an example
    # minium of 30 or you will get the error
    # Your Redis connection pool is too small for Sidekiq to work,
    # your pool has 10 connections but really needs to have at least 27
    redis_server_connection_number = Integer(ENV['REDIS_SERVER_SIZE'] || 30)
    config.redis = {
      url: ENV['REDIS_URL'],
      size: redis_server_connection_number,
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
    config.queues = %w[urgent_delivery,2 standard_delivery,1]

    # Number of concurrent workers pulling jobs and processing them
    # every one will use a database connection(postgresql) and a redis
    # connection(calculate based on your current plan)
    # By default Sidekiq uses 25 threads if you do not specify this value
    # NOTE: when increasing this value take into account the database connection and
    # puma threads in the config/puma.rb file
    sidekiq_concurrency = Integer(ENV['SIDEKIQ_CONCURRENCY_WORKERS'] || 5)
    config.concurrency = sidekiq_concurrency
  end
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  # Protect against timing attacks:
  # - See https://codahale.com/a-lesson-in-timing-attacks/
  # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
  # - Use & (do not use &&) so that it doesn't short circuit.
  # - Use digests to stop length information leaking
  ActiveSupport::SecurityUtils.secure_compare(user, ENV['SIDEKIQ_ADMIN_USER']) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV['SIDEKIQ_ADMIN_PASSWORD'])
end
