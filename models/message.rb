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

  def plivoize
    [from, [to], text]
  end

  def self.unplivoize(params)
    Message.new(external_id: params['MessageUUID'],
                from: params['From'],
                to: params['To'],
                direction: 'in',
                content: params['Text'])
  end
end
