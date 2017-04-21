require_relative 'app'

map '/' do 
  run App.new
end

require 'resque/server'

map '/resque' do
  run Resque::Server.new
end

