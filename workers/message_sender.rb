class MessageSender
  include Sidekiq::Worker

  def perform(message_id)
    message = Message.find(id: message_id)
    result = PLIVO_CLIENT.messages.create(*message.plivoize)
    message.update(external_id: result.message_uuid, state: 'sent')
  end
end
