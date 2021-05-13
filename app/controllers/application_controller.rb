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

  ['/users/*', "/items", "/items/*", "/carts/", "/placeorder/*"].each do |path|
    before path do
      redirect_if_not_logged_in
    end
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
        flash[:message] = ["You must be logged in to perform this action"]
        redirect to '/login'
      end
    end

    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

    def authorized_user_view?
      request = User.find_by_slug(params[:slug])
      if current_user != request
        flash[:message] = ["You can only see your own account"]
        redirect to "/users/#{current_user.slug}"
      end
    end

    def authorized_cart_view?
      request = Cart.find_by(id: params[:id])
      if request != nil && current_user.cart != request
        flash[:message] = ["You can only see your own cart"]
        redirect to "/carts/#{current_user.cart.id}"
      elsif request == nil
        not_found                 # Renders a 404 error page
      end
    end

    def authorized_item_view?
      item = Item.find_by(id: params[:id])
      if item && item.user_id != session[:user_id]
        flash[:message] = ["You can only edit or delete your own items"]
        redirect to "/users/#{current_user.slug}"
      elsif item == nil
        not_found                 # Renders a 404 error page
      end
    end
  end
  
end

