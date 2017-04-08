module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  post '/messages/send' do
    return 403 unless @current_user
    @message = Message.new(source: params['source'],
                           destination: params['destination'],
                           content: params['content'],
                           direction: 'outbound')
    @message.save
    PLIVO.send_message(@message.plivoize)
    return 200
  end

  post '/messages/receive' do
    return 403 unless params['token'] == settings.webhook_token
    @message = Message.unplivoize(params)
    @message.save
    return 200
  end
end
