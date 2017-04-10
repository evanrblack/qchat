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
      return @message.to_json
    elsif params['token'] == settings.webhook_token
      @message = Message.unplivoize(params)
      @contact = Contact.find_or_create(phone_number: @message.source)
      @message.save
      notify('new_message', @contact.to_json(include: %i[messages]))
      return 200
    end
  end
end
