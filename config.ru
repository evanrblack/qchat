require_relative 'app'
require 'sidekiq/web'

map '/' do 
  run App.new
end

map '/sidekiq' do
  run Sidekiq::Web
end
