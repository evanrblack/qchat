# Set application root for requires
APP_ROOT = File.expand_path(File.dirname(__FILE__))

# Initialize
require File.join(APP_ROOT, 'config', 'initialize')
require 'json'

# This class represents the actual web application.
class App < Sinatra::Base
  configure do
    enable :method_override
    register Sinatra::Flash
    register(PagesController,
             SessionsController,
             ContactsController,
             MessagesController)
    use Rack::Session::Cookie, key: 'rack.session',
                               domain: 'localhost',
                               path: '/',
                               expire_after: 2592000,
                               secret: 'change_me'
  end

  before do
    @current_user = User.find(id: session[:id]) if session[:id]
  end

  post '/receive' do
    # Access denied if webhook_token not present
    return 403 unless params['token'] == settings.webhook_token
    @message = Message.unplivoize(params)
    @message.save
    return 200
  end
end

