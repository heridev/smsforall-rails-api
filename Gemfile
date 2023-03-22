# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.7'
gem 'awesome_print'
gem 'bcrypt', require: 'bcrypt'
gem 'bootsnap', require: false
gem 'fast_jsonapi', git: 'https://github.com/fast-jsonapi/fast_jsonapi'
gem 'fcm'
gem 'jwt'
gem 'kaminari'
gem 'pg'
gem 'pry'
gem 'pry-byebug'
gem 'puma'
gem 'pusher'
gem 'rack-attack'
gem 'rack-cors'
gem 'rails', '~> 6.0.6.1'
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler'

group :development, :test do
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_bot'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

gem 'tzinfo-data'
