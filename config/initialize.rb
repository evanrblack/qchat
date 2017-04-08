require 'bundler'
Bundler.require

# ENV VARS
ENV['RACK_ENV'] ||= 'development'
Dotenv.load(".env.#{ENV['RACK_ENV']}")

# PLIVO
PLIVO = Plivo::RestAPI.new(ENV['PLIVO_AUTH_ID'], ENV['PLIVO_AUTH_TOKEN'])

# DATABASE + MODELS
# Load sequel and extensions / plugins
Sequel.extension :migration
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers
# Connect to database
Sequel.connect(ENV['DB_URL'])
# Run migrations
Sequel::Migrator.apply(Sequel::DATABASES.first, 'db/migrate')

# Load models and controllers
MODEL_DIR = File.join(APP_ROOT, 'models/*.rb')
CONTROLLER_DIR = File.join(APP_ROOT, 'controllers/*.rb')
Dir[MODEL_DIR, CONTROLLER_DIR].each do |file|
  require file
end

