module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['WEBHOOK_TOKEN']
  end

  post '/messages' do
    if @current_user
      to = params['to']
      text = params['text']
      @contact = Contact.find(phone_number: to,
                              user_id: @current_user.id)
      if @contact
        text.gsub!(/\$\w+/) do |prop|
          method = prop[1..-1]
          if @contact.methods.map(&:to_s).include? method
            @contact.send(method)
          else
            prop
          end
        end
      end
      @message = Message.create(type: 'sms',
                                direction: 'out',
                                external_id: nil,
                                from: @current_user.phone_number,
                                to: to,
                                text: text,
                                state: 'pending',
                                seen_at: Time.now)
      MessageSender.enqueue(@message)
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
        # Message from and to are normalized after save
        @user = User.find(phone_number: @message.to)
        @contact = Contact.find_or_create(phone_number: @message.from,
                                          user_id: @user.id)
        included = %i[messages unseen_messages_count]
        contact_json = @contact.to_json(include: included)
        notify(@user.id, 'new_message', contact_json)
      end
      @message.to_json
    else
      403
    end
  end

  patch '/messages/:id' do
    return 403 unless @current_user
    @message = Message.find(id: params['id'])
    # return 403 unless @current_user.received_messages.include? @message
    @message.update(seen_at: Time.now) if params['seen_at']
    @message.to_json
  end
end
