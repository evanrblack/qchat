web: rackup --port $PORT --env $RACK_ENV
release: rake db:migrate
worker: sidekiq -r ./app.rb
