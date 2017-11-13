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
# Simple task interface
gem 'rake'
# ORM, like ActiveRecord
gem 'sequel'
# REST client
gem 'faraday'
# Password hasher
gem 'bcrypt'
# Handles phone numbers
gem 'phony'
# Handles SMS
gem 'plivo', '>= 4.0.0.beta.2'
# Background job worker
gem 'sidekiq'

group :development do
  # Database adapter
  gem 'sqlite3'

  # Nicer interactive console
  gem 'pry', require: false
  # Static code analyzer
  gem 'rubocop', require: false
  # Fake data generator
  gem 'faker', require: false
  # Watches for changes
  gem 'rerun', require: false
end

group :production do
  # Database adapter
  gem 'pg'
end

group :test do
  # Pretty minitest results
  gem 'minitest-reporters'
end
