source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'
gem 'jwt', '~> 2.2.1'
gem 'rails', '~> 6.0.2.2'
gem 'pg', '~>1.2.3'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'pry'
gem 'pry-byebug'
gem 'bcrypt', '~> 3.1.13', require: 'bcrypt'
gem 'fast_jsonapi', '~> 1.7.1', git: 'https://github.com/fast-jsonapi/fast_jsonapi'
gem 'sidekiq', '~> 6.0.7'
gem 'fcm', '~> 1.0.1'
gem 'rack-cors', '~> 1.1.1'
gem 'kaminari'
gem 'awesome_print', '~> 1.8.0'
gem 'redis', '~> 4.1.4'
gem 'pusher', '~> 1.3.3'
gem 'rack-attack', '~> 6.2.2'

group :development, :test do
  gem 'rubocop', '~> 0.82.0', require: false
end

group :test do
  gem 'rspec-rails', '~> 4.0.0'
  gem 'factory_bot', '~> 5.2.0'
  gem 'fakeredis', require: 'fakeredis/rspec'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data'
