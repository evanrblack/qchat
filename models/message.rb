class Message < Sequel::Model
  def validate
    super
    validates_presence %i[type direction external_id from to text state]
    %i[from to].each do |side|
      number = send(side)
      errors.add(side, 'is invalid') unless Phony.plausible?(number, cc: '1')
    end
  end

  def before_validation
    super
    self.from = Phony.normalize(source) if from
    self.to = Phony.normalize(destination) if to
  end

  def contact
    Contact.find(phone_number: from)
  end
end
