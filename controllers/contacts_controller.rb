module ContactsController
  extend Sinatra::Extension

  get '/contacts' do
    return 403 unless @current_user
    @contacts = Contact.all.map do |c|
      {
        id: c.id,
        name: c.name,
        phoneNumber: c.phone_number
      }
    end
    json @contacts
  end

  get '/contacts/:id' do
    return 403 unless @current_user
    @contact = Contact.find(id: id)
    json @contact
  end

  get '/contacts/:id/messages' do
    return 403 unless @current_user
    @contact = Contact.find(id: id)
    @messages = @contact.messages
    json @messages
  end
end
