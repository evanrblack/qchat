module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  post '/messages' do
    @token_match = params['token'] == settings.webhook_token
    return 403 unless @current_user || @token_match
    if @current_user
      @message = Message.new(source: ENV['PLIVO_PHONE_NUMBER'],
                             destination: params['destination'],
                             direction: 'outbound',
                             content: params['content'])
      @message.save
      PLIVO.send_message(@message.plivoize)
    elsif params['token'] == settings.webhook_token
      @message = Message.unplivoize(params)
      @message.save
    end
    json @message
  end
end
