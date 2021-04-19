require './config/environment'
require 'rack-flash'
class ApplicationController < Sinatra::Base
  configure do
    enable :sessions
    use Rack::Flash
    set :session_secret, "password_security"
    set :public_folder, "public"
    set :views, 'app/views'
  end

  get '/' do 
    erb :index
  end

  get '/index' do
    erb :index
  end

  # Application wide helpers
  helpers do
    def redirect_if_not_logged_in
      if !logged_in?
        flash[:message] = "You must be logged in to perform this action"
        redirect to '/login'
      end
    end

    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
  
end