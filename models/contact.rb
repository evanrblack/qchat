class Contact < Sequel::Model
  many_to_one :user

  def validate
    super
    validates_presence %i[user_id phone_number]
    unless Phony.plausible?(phone_number, cc: '1')
      errors.add(:phone_number, 'is invalid')
    end
  end

  def before_validation
    super
    self.phone_number = Phony.normalize(phone_number, cc: '1') if phone_number
  end

  def messages
    sent_messages.union(received_messages)
  end

  def sent_messages
    Message.where(from: phone_number, to: user.phone_number)
  end

  def received_messages
    Message.where(to: phone_number, from: user.phone_number)
  end

  def unseen_messages_count
    sent_messages.where(seen_at: nil).count
  end

  def unresponsive
    sent_messages.empty?
  end
end
