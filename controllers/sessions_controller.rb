module SessionsController
  extend Sinatra::Extension

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.find(email: params['email'])
    password = BCrypt::Password.new(user.password_hash) if user

    # BCrypt pass must be on left of equality
    if user && password == params['password']
      session[:id] = user.id
      redirect '/'
    else
      flash[:danger] = 'Invalid email or password'
      redirect '/login'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end
end

