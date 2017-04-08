module ContactsController
  extend Sinatra::Extension

  get '/contacts' do
    return 403 unless @current_user
    json Contact.all
  end

  get '/contacts/:id' do
    return 403 unless @current_user
    @contact = Contact.find(id: id)
  end
end
