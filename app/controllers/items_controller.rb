class ItemsController < ApplicationController
  #before_action :require_login                                     <---------- implement
  #skip_before_action :require_login, only: [:index]
 

  # def require_login                                               <--------- implement
  #   return head(:forbidden) unless session.include? :user_id
  # end

  get '/items' do
    redirect_if_not_logged_in
    @items= Item.all
    erb :'items/items'
  end

  get '/items/new' do
    redirect_if_not_logged_in
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
      stock = params[:stock]
      @item.handle_stock(stock)
      redirect to "/items/#{@item.id}"
    end
  end

  get '/items/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    if @item.status == "listing" && @item.user == current_user
      erb :'items/show_item'
    else
      erb :'items/show_item_buy'
    end
  end

  get '/items/:id/edit' do
    @item= Item.find(params[:id])
    erb :'items/edit_item'
  end

  patch '/items/:id' do                           #THe logic here is a little bit complex; if a user wants to edit a listing, the the appplication has to find all of the instances of the corresponding                       
    redirect_if_not_logged_in                     # (cont.) item in that listing, change the attributes of those instances using the user's params, and then make copies or delete copies of those instances if the params stock is greater or lower than the original stock.
    @user= current_user                            
    @item = Item.find(params[:id])
    no_empty_params?
    valid_stock?
    @user.items.collect do |item|
      if item.name == @item.name && item.status == "listing"
        item.name = params[:name]
        item.price = params[:price]
        item.save
      end
    end
    @item= current_user.items.find {|item| item.name == params[:name] && item.status == "listing"}
    handle_stock
    @item= current_user.items.find {|item| item.name == params[:name] && item.status == "listing"}
    redirect to "/items/#{@item.id}"
  end

  delete '/items/:id' do
    redirect_if_not_logged_in
    @item = Item.find(params[:id])
    if @item.user == current_user
      all_stock= @item.stock
      all_stock.times {
        destroy_item= current_user.items.find {|item| item.name == @item.name && item.status == "listing"}
        destroy_item.delete
      }
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

    def handle_stock
      if params[:stock].to_i > @item.stock
        add_items
      elsif params[:stock].to_i < @item.stock
        subtract_items
      end
    end
   
    def add_items
      add = params[:stock].to_i - @item.stock 
      add.times {
        new_item= Item.new(name: @item.name, price: @item.price, status: "listing")
        new_item.user = current_user
        new_item.save
      }
    end

    def subtract_items
      subtract = @item.stock - params[:stock].to_i
      subtract.times {
        destroy_item= current_user.items.find {|item| item.name == params[:name] && item.status == "listing"}
        destroy_item.delete
      }
    end  
    
  end


end