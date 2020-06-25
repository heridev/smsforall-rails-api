# take into account database connections total when increasing this
# values for that look at the database.yml into the pool section
min_threads = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads = Integer(ENV['PUMA_MAX_THREADS'] || 3)

# 1 thread means 1 request served
# threads minimum_threads_available, maximum_threads_available per worker
threads min_threads, max_threads

port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# puma workers are copies of your application and that
# means every copy will handle its own threads
workers Integer(ENV['WEB_CONCURRENCY'] || 1)

preload_app!

before_fork do
  ActiveRecord::Base.connection.disconnect!

  if Rails.env.staging? || Rails.env.development?
    @sidekiq_pid ||= spawn('bundle exec sidekiq -c 2 -q default -q mailers')
  end
end

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

on_restart do
  Sidekiq.redis.shutdown { |conn| conn.close }
end
