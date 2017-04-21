# frozen_string_literal: true
source 'https://rubygems.org'

# Simple web framework
gem 'sinatra'

# Extensions for Sinatra
gem 'sinatra-contrib'

# Flashes for Sinatra
gem 'sinatra-flash'

# Additions to Rack
gem 'rack-contrib'

# Fast and simple web server
gem 'thin'

# Communication with Redis
gem 'redis'

# Simple task interface
gem 'rake'

# Easy background jobs using Redis
gem 'resque'

# ORM, like ActiveRecord
gem 'sequel'

# REST client
gem 'faraday'

# Manage environment variables
gem 'dotenv'

# Send and receive SMS messages
gem 'ruby-bandwidth'

# Password hasher
gem 'bcrypt'

# Handles phone numbers
gem 'phony'

# Database adapter
gem 'sqlite3'

group :development do
  # Deployment tool
  gem 'capistrano', require: false
  # RVM tasks for Capistrano
  gem 'capistrano-rvm', require: false
  # Bundler tasks for Capistrano
  gem 'capistrano-bundler', require: false
  # Thin tasks for Capistrano
  gem 'capistrano-thin', require: false

  # Nicer interactive console
  gem 'pry', require: false

  # Static code analyzer
  gem 'rubocop', require: false

  # Fake data generator
  gem 'faker', require: false
end

group :production do
end

group :test do
  # Pretty minitest results
  gem 'minitest-reporters'
end
