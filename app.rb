require 'bundler'
Bundler.require

# ENV VARS
ENV['RACK_ENV'] ||= 'development'
Dotenv.load("./.env.#{ENV['RACK_ENV']}")

# PLIVO
PLIVO = Plivo::RestAPI.new(ENV['PLIVO_AUTH_ID'], ENV['PLIVO_AUTH_TOKEN'])

# DATABASE + MODELS
# Load sequel and extensions / plugins
Sequel.extension :migration
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers
# Connect to database
DB = Sequel.connect(ENV['DB_URL'])
# Run migrations
Sequel::Migrator.apply(DB, 'db/migrate')
# Load models

# This class represents the actual web application.
class App < Sinatra::Base
  configure do
    enable :sessions
    register Sinatra::Flash

    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  before do
    @current_user = User.find(id: session[:id]) if session[:id]
  end

  get '/' do
    erb(@current_user ? :dashboard : :index)
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.find(email: params['email'])
    password = BCrypt::Password.new(user.password_hash) if user

    # BCrypt pass must be on left of equality
    if user && password == params['password']
      session[:id] = user.id
      redirect '/'
    else
      flash[:danger] = 'Invalid email or password'
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/send' do
    @message = Message.new(source: params['source'],
                           destination: params['destination'],
                           content: params['content'],
                           direction: 'outbound')
    @message.save
    PLIVO.send_message(@message.plivoize)
    return 200
  end

  post '/receive' do
    # Access denied if webhook_token not present
    return 403 unless params['token'] == settings.webhook_token
    @message = Message.unplivoize(params)
    @message.save
    return 200
  end
end

# Load models, routes
Dir['models/*.rb', 'routes/*.rb'].each { |file| require_relative file }
