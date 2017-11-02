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
    set :connections, {}
  end

  def notify(user_id, type, content)
    # Sequels to_json has nice optionals that to_hash doesnt
    content_hash = JSON.parse(content)
    outs = settings.connections[user_id]
    if outs
      outs.each do |out|
        out << "data: #{{ type: type, content: content_hash }.to_json}\n\n"
      end
    end
  end

  get '/stream', provides: 'text/event-stream' do
    return 403 unless @current_user
    headers 'X-Accel-Buffering' => 'no'
    stream(:keep_open) do |out|
      id = @current_user.id
      connections = settings.connections
      connections[id] ||= []
      connections[id] << out
      
      out.callback do
        connections[id].delete(out)
        connections.delete(id) if connections[id].empty?
      end

      while connections[id]
        count = Resque.size("pending_messages_#{id}")
        notify(id, "pending_messages", { count: count }.to_json)
        sleep 5
      end
    end
  end

  before do
    @current_user = User.find(id: session[:id]) if session[:id]
  end
end
