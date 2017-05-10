class User < Sequel::Model
  one_to_many :contacts
  
  attr_accessor :password

  def validate
    super
    validates_presence %i[email password_hash]
    validates_unique :email
  end

  def before_validation
    if password && !password_hash
      self.password_hash = BCrypt::Password.create(password)
    end
  end

  def messages
    sent_messages.union(received_messages)
  end

  def sent_messages
    Message.where(from: phone_number)
  end

  def received_messages
    Message.where(to: phone_number)
  end
end
