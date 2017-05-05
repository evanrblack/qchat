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
end
