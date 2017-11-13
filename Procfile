web: rackup --port $PORT --env $RACK_ENV
release: rake db:migrate
worker: rake resque:work QUEUE=pending_messages
