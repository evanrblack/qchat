require 'csv'

module ContactsController
  extend Sinatra::Extension

  get '/contacts', provides: :json do
    return 403 unless @current_user
    Contact.where(user_id: @current_user.id)
           .to_json(only: %i[id first_name last_name lead_source phone_number
                             unseen_messages_count unresponsive])
  end

  post '/contacts', provides: :json do
    return 403 unless @current_user
    if params['file']
      CSV.foreach(params['file'][:tempfile], headers: true) do |row|
        phone_number = Phony.normalize(row['phone_number'], cc: '1')
        contact = Contact.find_or_create(user_id: @current_user.id, phone_number: phone_number)
        %w[first_name last_name email lead_source].each do |attr|
          contact.send("#{attr}=", row[attr]) if row[attr]
        end
        if row['wedding_date']
          fixed_date = begin
                         Date.strptime(row['wedding_date'], '%m/%d/%Y')
                       rescue
                         nil
                       end
          contact.wedding_date = fixed_date
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
    @contact.update_all(params)
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
