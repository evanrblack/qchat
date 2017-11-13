module MessagesController
  extend Sinatra::Extension

  configure do
    set :webhook_token, ENV['PLIVO_WEBHOOK_TOKEN']
  end

  helpers do
    def send_message
      to = params['to']
      text = params['text']
      @contact = Contact.find(phone_number: to,
                              user_id: @current_user.id)

      text = substituted_values(text, @contact) if @contact

      @message = Message.create(type: 'sms',
                                direction: 'out',
                                external_id: nil,
                                from: @current_user.phone_number,
                                to: to,
                                text: text,
                                state: 'pending',
                                seen_at: Time.now)

      MessageSender.perform_async(@message.id)
      @message.to_json
    end

    def substituted_values(text, contact)
      text.gsub(/\$\w+/) do |prop|
        method = prop[1..-1]
        if contact.methods.map(&:to_s).include? method
          contact.send(method)
        else
          prop
        end
      end
    end

    def receive_message
      # Callback for both sent and received messages
      @message = Message.create(type: params['Type'],
                                direction: 'in',
                                external_id: params['MessageUUID'],
                                from: params['From'],
                                to: params['To'],
                                text: params['Text'],
                                state: 'unknown')
      # Message from and to are normalized after save
      @user = User.find(phone_number: @message.to)
      @contact = Contact.find_or_create(phone_number: @message.from,
                                        user_id: @user.id)
      included = %i[messages unseen_messages_count unresponsive]
      contact_json = @contact.to_json(include: included)
      notify(@user.id, 'new_message', contact_json)
      @message.to_json
    end
  end

  post '/messages' do
    if @current_user
      send_message
    elsif params['token'] == settings.webhook_token
      receive_message
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
