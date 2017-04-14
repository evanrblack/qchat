class Contact < Sequel::Model
  def validate
    super
    validates_presence %i[phone_number]
    unless Phony.plausible?(phone_number, cc: '1')
      errors.add(:phone_number, 'is invalid')
    end
  end

  def before_validation
    super
    self.phone_number = Phony.normalize(phone_number, cc: '1') if phone_number
  end

  def messages
    Message.where('`from` = ? OR `to` = ?', phone_number, phone_number)
           .order(:created_at)
  end

  def sent_messages
    Message.where(from: phone_number)
  end

  def received_messages
    Messages.where(to: phone_number)
  end
end
