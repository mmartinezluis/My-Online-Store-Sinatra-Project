require '../config/environment'
require 'rack-flash'
class ApplicationController <Sinatra::Base

  configure do
    enable :sessions
    use Rack::flash
    set :session_secret, "password_security"
    set :public_folder, "public"
    set :views, 'app/viesw'
  end

  get '/' do 
    erb :index
  end

  get '/index' do
    erb :index
  end

  helpers do
    def logged_in
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
  
end