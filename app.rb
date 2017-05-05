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
                               expire_after: 2_592_000,
                               secret: ENV['SECRET_TOKEN'] || 'change_me'
    use Rack::PostBodyContentTypeParser
    helpers Sinatra::Streaming
    set :connections, []
  end

  def notify(user_id, type, content)
    # Sequels to_json has nice optionals that to_hash doesnt
    content_hash = JSON.parse(content)
    logger.debug "event: { type: #{type}, content: #{content_hash}}"
    out = settings.connections[user_id]
    if out
      out << "data: #{{ type: type, content: content_hash }.to_json}\n\n"
    end
  end

  get '/stream', provides: 'text/event-stream' do
    return 403 unless @current_user
    headers 'X-Accel-Buffering' => 'no'
    stream(:keep_open) do |out|
      settings.connections[@current_user.id] = out
      out.callback { settings.connections.delete(@current_user.id) }
    end
  end

  before do
    @current_user = User.find(id: session[:id]) if session[:id]
  end
end
