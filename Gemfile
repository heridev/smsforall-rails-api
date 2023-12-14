# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'
gem 'awesome_print'
gem 'bcrypt', require: 'bcrypt'
gem 'bootsnap', require: false
gem 'fcm'
gem 'jsonapi-serializer'
gem 'jwt'
gem 'kaminari'
gem 'pg'
gem 'pry'
gem 'pry-byebug'
gem 'psych', '< 4'
gem 'puma'
gem 'pusher'
gem 'rack-attack'
gem 'rack-cors'
gem 'rails', '~> 6.0.6.1'
gem 'redis', '5.0.8'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler'

group :development, :test do
  gem 'dotenv-rails'
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_bot'
  gem 'fakeredis', github: 'heridev/fakeredis', require: 'fakeredis/rspec'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  # gem 'spring'
  # gem 'spring-watcher-listen'
end

gem 'tzinfo-data'
