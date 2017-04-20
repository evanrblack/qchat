class Message < Sequel::Model
  def validate
    super
    validates_presence %i[type direction from to text state]
    %i[from to].each do |side|
      number = send(side)
      errors.add(side, 'is invalid') unless Phony.plausible?(number, cc: '1')
    end
  end

  def before_validation
    super
    self.from = Phony.normalize(from) if from
    self.to = Phony.normalize(to) if to
  end

  def contact
    Contact.find(phone_number: from)
  end
end
