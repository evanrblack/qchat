require 'bundler'
Bundler.require
require 'json'

# ENV VARS
ENV['RACK_ENV'] ||= 'development'
Dotenv.load(".env.#{ENV['RACK_ENV']}")

# BANDWIDTH
BANDWIDTH_CLIENT =
  Bandwidth::Client.new(user_id: ENV['BANDWIDTH_USER_ID'],
                        api_token: ENV['BANDWIDTH_API_TOKEN'],
                        api_secret: ENV['BANDWIDTH_API_SECRET'])

# DATABASE + MODELS
# Set UTC as default
Sequel.default_timezone = :utc
# Load sequel and extensions / plugins
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :json_serializer
# Turn off strict param setting
Sequel::Model.strict_param_setting = false
# Connect to database
Sequel.connect(ENV['DB_URL'])

# Load models, controllers, and jobs
MODEL_DIR = File.join(APP_ROOT, 'models/*.rb')
CONTROLLER_DIR = File.join(APP_ROOT, 'controllers/*.rb')
JOB_DIR = File.join(APP_ROOT, 'jobs/*.rb')
Dir[MODEL_DIR, CONTROLLER_DIR, JOB_DIR].each do |file|
  require file
end
