class MessageSender
  def self.enqueue(message)
    user = User.find(phone_number: message.from)
    queue = "pending_messages_#{user.id}"
    Resque::Job.create(queue, self, message.id)
  end

  def self.perform(message_id)
    message = Message.find(id: message_id)
    options = { from: message.from, to: message.to, text: message.text }
    result = Bandwidth::Message.create(BANDWIDTH_CLIENT, options)
    message.update(external_id: result[:message_id], state: result[:state])
  end
end

