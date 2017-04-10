class Message < Sequel::Model
  def validate
    super
    validates_presence %i[external_id source destination content]
    %i[source destination].each do |side|
      number = send(side)
      errors.add(side, 'is invalid') unless Phony.plausible?(number, cc: '1')
    end
  end

  def before_validation
    super
    self.source = Phony.normalize(source) if source
    self.destination = Phony.normalize(destination) if destination
  end

  def contact
    Contact.find(phone_number: source)
  end

  # Prepare the message to send to Plivo
  def plivoize
    {
      src: source,
      dst: destination,
      text: content
    }
  end

  # Turn Plivo data into Message
  def self.unplivoize(params)
    Message.new(external_id: params['MessageUUID'],
                source: params['From'],
                destination: params['To'],
                direction: 'inbound',
                content: params['Text'])
  end
end
