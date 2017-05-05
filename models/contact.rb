class Contact < Sequel::Model
  many_to_one :user

  def validate
    super
    validates_presence %i[user_id phone_number]
    if wedding_date && !wedding_date.is_a?(Date)
      errors.add(:wedding_date, 'is invalid')
    end
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
end
