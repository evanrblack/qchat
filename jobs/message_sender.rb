class MessageSender
  @queue = :pending_messages

  def self.perform(message_id)
    message = Message.find(id: message_id)
    options = { from: message.from, to: message.to, text: message.text }
    result = Bandwidth::Message.create(BANDWIDTH_CLIENT, options)
    message.update(external_id: result[:messageId], state: result[:state])
  end
end

