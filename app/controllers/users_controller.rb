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
    authorized_user_view?
    @user = User.find_by_slug(params[:slug])
    erb :'users/show' 
  end

  get '/all-my-listings' do
    @user = current_user
    erb :'users/listings'
  end

  get '/purchases' do
    @user = current_user
    erb :'users/purchases'
  end
      

  
end