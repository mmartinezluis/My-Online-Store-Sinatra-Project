class UsersController < ApplicationController
  get '/signup' do
    if !logged_in?
      erb :'users/signup'
    else
      redirect to '/items'
    end
  end

  post '/signup' do
    @user= User.new(:username => params[:username], :email => params[:email], :password => params[:password])
    if @user.valid?
      @user.funds = 100.00
      @user.cart = Cart.new
      @user.save
      session[:user_id] = @user.id
      redirect to '/items'
    else
      #flash[:message] = ["All fields mus be completed"] 
      flash[:message] = @user.errors.full_messages
      redirect to '/signup'
    end
  end

  get '/users/:slug' do
    redirect_if_not_logged_in
    @user = User.find_by_slug(params[:slug])
    erb :'users/show' 
  end
      
  get '/logout' do
    if logged_in?
      session.clear
      redirect to '/login'
    else
      redirect to '/'
    end
  end
  
end