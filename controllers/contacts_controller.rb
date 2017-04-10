module ContactsController
  extend Sinatra::Extension

  get '/contacts', provides: :json do
    return 403 unless @current_user
    Contact.to_json
  end

  post '/contacts', provides: :json do
    return 403 unless @current_user
    Contact.create(phone_number: params['phone_number']).to_json
  end

  get '/contacts/:id', provides: :json do
    return 403 unless @current_user
    Contact.find(id: params['id']).to_json
  end

  patch '/contacts/:id', provides: :json do
    return 403 unless @current_user
    @contact = Contact.find(id: params['id'])
    @contact.update_fields(params, %i[first_name last_name
                                      email wedding_date
                                      phone_number lead_source])
    @contact.to_json
  end

  get '/contacts/:id/messages', provides: :json do
    return 403 unless @current_user
    Contact.find(id: params[:id]).messages.to_json
  end
end
