require 'pry'

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
      response = PLIVO.send_message(@message.plivoize)
      @message.external_id = response[1]['message_uuid'][0]
      @message.save
    elsif params['token'] == settings.webhook_token
      @message = Message.unplivoize(params)
      if @message.contact.nil?
        @contact = Contact.create(phone_number: @message.source)
        notify('new_contact', @contact.to_json)
      end
      @message.save
      notify('new_message', @contact.to_json(include: %i[message]))
    end
    @message.to_json
  end
end
