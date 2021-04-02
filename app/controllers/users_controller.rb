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
    if @user.save
      @user.funds = 100.00
      @user.cart = Cart.new
      @user.save
      session[:user_id] = @user.id
      redirect to '/items'
    elsif params[:username].empty? || params[:email].empty? || params[:password].empty?
      flash[:message] = "All fields must be completed"
      redirect to '/signup'
    else 
      flash[:message] = "This username #{@user.errors[:username][0]}"
      redirect to '/signup'
    end
  end

  get '/login' do
    if !logged_in?
      erb :'users/login'
    else
      redirect to '/items'
    end
  end

  post '/login' do
    @user= User.find_by(:username => params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect to '/items'
    else
      flash[:message] = "Invalid Username and/or Password"
      erb :'users/login'
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