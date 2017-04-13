module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  post '/messages' do
    if @current_user
      # Don't save model here; bandwidth will send callback for sent message
      options = {
        from: @current_user.phone_number,
        to: params['to'],
        text: params['text']
      }
      Bandwidth::Message.create(BANDWIDTH_CLIENT, options)
    elsif params['token'] == settings.webhook_token
      # Callback for both sent and received messages
      @message = Message.new(type: params['eventType'],
                             direction: params['direction'],
                             external_id: params['messageId'],
                             from: params['from'],
                             to: params['to'],
                             text: params['text'],
                             state: params['state'])
      @message.save
      if @message.direction == 'in'
        @contact = Contact.find_or_create(phone_number: @message.from)
        notify('new_message', @contact.to_json(include: %i[messages]))
      end
    else
      return 403
    end
  end
end
