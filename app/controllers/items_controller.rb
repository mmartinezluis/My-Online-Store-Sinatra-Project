class ItemsController < ApplicationController
  #before_action :require_login                                     <---------- implement
  #skip_before_action :require_login, only: [:index]
  
  # ['/join', "/join/*", "/payment/*"].each do |path|
  #   before path do
  #       #some code
  #   end
  # end

  # def require_login                                               <--------- implement
  #   return head(:forbidden) unless session.include? :user_id
  # end

  get '/items' do
    redirect_if_not_logged_in
    @items= Item.all
    erb :'items/index'
  end

  get '/items/new' do
    redirect_if_not_logged_in
    @item= Item.new
    @user = current_user
    erb :'items/new'
  end

  post '/items' do
    redirect_if_not_logged_in                                                                              #Third, if the stock if out of range, reload the form (incalid stock input)
    no_empty_params?                                                                                           #It might be that the user is putting info for a listing that already exiists in the user's listings                                                                               
    valid_stock?                                                                                             #First, check whether the user is logged in; if not, redirect to login                                                                                              
    if item_already_exists? 
      flash[:message] = ["You already have a listing with that item's name"]                                                                                  #Fourth, if the current user already has an item whose name matches the params[:name], reload the form
      redirect to "/items/new"                                                                    #Sedcond, check whether all form fields are populated; if not, reaload the form
    else
      @item= Item.new(name: params[:name], price: params[:price], status: "listing")
      @item.user = current_user
      @item.save
      @item.handle_stock(params[:stock])
      redirect to "/items/#{@item.id}"
    end
  end

  get '/items/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    erb :'items/show_item'
  end

  get '/items/:id/edit' do
    @item= Item.find(params[:id])
    erb :'items/edit_item'
  end

  patch '/items/:id' do                           #THe logic here is a little bit complex; if a user wants to edit a listing, the the appplication has to find all of the instances of the corresponding                       
    redirect_if_not_logged_in                     # (cont.) item in that listing, change the attributes of those instances using the user's params, and then make copies or delete copies of those instances if the params stock is greater or lower than the original stock.                           
    @item = Item.find(params[:id])
    no_empty_params?
    valid_stock?
    @item.all_stock.each do |item|
      item.name = params[:name]
      item.price = params[:price]
      item.save
    end
    @item = current_user.items.find_by(name: params[:name], status:"listing")
    @item.handle_stock(params[:stock])
    @item = current_user.items.find_by(name: params[:name], status:"listing")
    redirect to "/items/#{@item.id}"
  end

  delete '/items/:id' do
    redirect_if_not_logged_in
    @item = Item.find(params[:id])
    if @item.user == current_user
      @item.all_stock.each do |item|
        item.delete
      end
    end
    redirect to "/users/#{current_user.slug}"
  end


  helpers  do
    def no_empty_params?
      unless !params[:name].empty? && !params[:price].empty? && !params[:stock].empty?
        if @item
          flash[:message]= ["All fields must be completed"]
          redirect to "/items/#{@item.id}/edit"
        else
          flash[:message]= ["All fields must be completed"]
          redirect to "/items/new"
        end
      end
    end

    def valid_stock?
      unless (1..99).include?(params[:stock].to_i)
        if @item
          flash[:message]= ["Stock must be between 1 and 99"]
          redirect to "/items/#{@item.id}/edit"
        else
          flash[:message]= ["Stock must be between 1 and 99"]
          redirect to "/items/new"
        end
      end
    end

    def item_already_exists?
      current_user.items.find_by(name: params[:name], status: "listing")
    end    
  end

end