class MessageSender
  def self.enqueue(message)
    user = User.find(phone_number: message.from)
    queue = "pending_messages_#{user.id}"
    Resque::Job.create(queue, self, message.id)
  end

  def self.perform(message_id)
    message = Message.find(id: message_id)
    result = PLIVO_CLIENT.messages.create(*message.plivoize)
    message.update(external_id: result.message_uuid, state: 'sent')
  end
end

