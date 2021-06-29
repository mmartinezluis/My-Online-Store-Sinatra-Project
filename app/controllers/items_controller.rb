class ItemsController < ApplicationController

  # Index action
  get '/items' do
    @items = User.all_users_listings
    erb :'items/index'
  end

  # New action
  get '/items/new' do
    @item= Item.new
    erb :'items/new'
  end

  # Create action
  post '/items' do                                                                                            #Third, if the stock if out of range, reload the form (incalid stock input)
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
      flash[:message] = ["Listing successfully created"]
      redirect to "/items/#{@item.id}"
    end
  end

  # Show action
  get '/items/:id' do
    @item = Item.find_by(id: params[:id])
    if @item
      erb :'items/show_item'
    else
      flash[:message] = ["Item not found"]
      redirect to "/items"
    end
  end

  # Edit action
  get '/items/:id/edit' do
    authorized_item_view?
    @item= Item.find(params[:id])
    erb :'items/edit_item'
  end

  # Update action
  #THe logic here is a little bit complex; if a user wants to edit a listing, the the appplication has to find all of the instances of the corresponding                       
  # (cont.) item in that listing, change the attributes of those instances using the user's params, and then make copies or delete copies of those instances if the params stock is greater or lower than the original stock.                           
  patch '/items/:id' do                                                             
    @item = Item.find(params[:id])
    no_empty_params?
    valid_stock?
    @item.all_stock.each do |item|
      item.name = params[:name]
      item.price = params[:price]
      item.save
    end
    @item = current_user.items.find_by(name: params[:name], status: :listing)
    @item.handle_stock(params[:stock])
    @item = current_user.items.find_by(name: params[:name], status: :listing)
    flash[:message] = ["Listing successfully updated"]
    redirect to "/items/#{@item.id}"
  end

  # Delete action
  delete '/items/:id' do
    authorized_item_view?
    @item = Item.find(params[:id])
    @item.all_stock.each do |item|
      item.delete
    end
    flash[:message] = ["Listing successfully destroyed"]
    redirect to "/users/#{current_user.slug}"
  end


  helpers  do
    def no_empty_params?
      unless !params[:name].empty? && !params[:price].empty? && !params[:stock].empty?
        flash[:message]= ["All fields must be completed"]
        if @item
          redirect to "/items/#{@item.id}/edit"
        else
          redirect to "/items/new"
        end
      end
    end

    def valid_stock?
      unless (1..99).include?(params[:stock].to_i)
        flash[:message]= ["Stock must be between 1 and 99"]
        if @item
          redirect to "/items/#{@item.id}/edit"
        else
          redirect to "/items/new"
        end
      end
    end

    def item_already_exists?
      current_user.items.find_by(name: params[:name], status: :listing)
    end    
  end

end