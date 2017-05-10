require 'csv'

module ContactsController
  extend Sinatra::Extension

  get '/contacts', provides: :json do
    return 403 unless @current_user
    Contact.where(user_id: @current_user.id)
           .to_json(only: %i[id first_name last_name phone_number
                             unseen_messages_count])
  end

  post '/contacts', provides: :json do
    return 403 unless @current_user
    if params['file']
      CSV.foreach(params['file'][:tempfile], headers: true) do |row|
        contact = Contact.new(user_id: @current_user.id)
        %w[first_name last_name email phone_number lead_source].each do |attr|
          contact.send("#{attr}=", row[attr])
        end
        fixed_date = begin
                       Date.strptime(row['wedding_date'], '%m/%d/%Y')
                     rescue
                       nil
                     end
        contact.wedding_date = fixed_date

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

  get '/contacts/:id/messages', provides: :json do
    return 403 unless @current_user
    Contact.find(id: params[:id], user_id: @current_user.id).messages.to_json
  end
end
