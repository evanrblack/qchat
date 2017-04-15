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

group :development do
  # Database adapter
  gem 'sqlite3'

  # Deployment tool
  gem 'capistrano'
  # RVM tasks for Capistrano
  gem 'capistrano-rvm'
  # Bundler tasks for Capistrano
  gem 'capistrano-bundler'
  # Thin tasks for Capistrano
  gem 'capistrano-thin'
  # Resque tasks for Capistrano
  gem 'capistrano-resque'

  # Nicer interactive console
  gem 'pry', require: false

  # Static code analyzer
  gem 'rubocop', require: false

  # Fake data generator
  gem 'faker', require: false
end

group :production do
  # Database adapter... for now
  gem 'sqlite3'
end

group :test do
  # Pretty minitest results
  gem 'minitest-reporters'
end
