ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

# Make output prettier
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative '../cake_sprint.rb'
