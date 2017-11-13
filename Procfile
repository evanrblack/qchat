web: bundle exec rackup --port $PORT --env $RACK_ENV
release: bundle exec rake db:migrate
worker: bundle exec sidekiq -r ./app.rb -c 4
