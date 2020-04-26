source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'
gem 'jwt', '~> 2.2.1'
gem 'rails', '~> 6.0.2.2'
gem 'pg', '~>1.2.3'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'pry'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rubocop', '~> 0.82.0', require: false
  gem 'rspec-rails', '~> 4.0.0'
  gem 'factory_bot', '~> 5.2.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data'
