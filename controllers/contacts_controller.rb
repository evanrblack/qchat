require 'csv'

module ContactsController
  extend Sinatra::Extension

  get '/contacts', provides: :json do
    return 403 unless @current_user
    Contact.where(user_id: @current_user.id)
           .to_json(only: %i[id first_name last_name tags phone_number
                             unseen_messages_count unresponsive])
  end

  post '/contacts', provides: :json do
    return 403 unless @current_user
    if params['file']
      CSV.foreach(params['file'][:tempfile], headers: true) do |row|
        phone_number = Phony.normalize(row['phone_number'], cc: '1')
        contact = Contact.find_or_create(user_id: @current_user.id, phone_number: phone_number)
        %w[first_name last_name email tags].each do |attr|
          contact.send("#{attr}=", row[attr]) if row[attr]
        end
        begin
          contact.save
        rescue
          nil
        end
      end
      redirect '/'
    else
      Contact.create(user_id: @current_user.id,
                     phone_number: params['phone_number']).to_json
    end
  end

  get '/contacts/:id', provides: :json do
    return 403 unless @current_user
    Contact.find(id: params['id'], user_id: @current_user.id).to_json
  end

  patch '/contacts/:id', provides: :json do
    return 403 unless @current_user
    @contact = Contact.find(id: params['id'], user_id: @current_user.id)
    @contact.update(params)
    @contact.to_json
  end

  delete '/contacts/:id', provides: :json do
    return 403 unless @current_user
    @contact = Contact.find(id: params['id'], user_id: @current_user.id)
    @contact.delete
    @contact.to_json
  end

  get '/contacts/:id/messages', provides: :json do
    return 403 unless @current_user
    Contact.find(id: params[:id], user_id: @current_user.id).messages.to_json
  end
end
