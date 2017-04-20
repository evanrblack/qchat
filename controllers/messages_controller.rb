module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  post '/messages' do
    if @current_user
      @message = Message.create(type: 'sms',
                                direction: 'out',
                                external_id: nil,
                                from: @current_user.phone_number,
                                to: params['to'],
                                text: params['text'],
                                state: 'pending')
      Resque.enqueue(MessageSender, @message.id)
      @message.to_json
    elsif params['token'] == settings.webhook_token
      # Callback for both sent and received messages
      @message = Message.create(type: params['eventType'],
                                direction: params['direction'],
                                external_id: params['messageId'],
                                from: params['from'],
                                to: params['to'],
                                text: params['text'],
                                state: params['state'])
      if @message.direction == 'in'
        @contact = Contact.find_or_create(phone_number: @message.from)
        notify('new_message', @contact.to_json(include: %i[messages]))
      end
      @message.to_json
    else
      return 403
    end
  end
end
