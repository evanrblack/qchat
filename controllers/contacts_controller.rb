module ContactsController
  extend Sinatra::Extension

  get '/contacts/:id' do
    @contact = Contacts.find(id: id)
  end
end
