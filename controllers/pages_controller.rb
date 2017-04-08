module PagesController
  extend Sinatra::Extension

  get '/' do
    erb(@current_user ? :dashboard : :index)
  end
end
