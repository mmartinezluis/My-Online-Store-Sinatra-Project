class ItemsController < ApplicationController

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
    redirect_if_not_logged_in                                                                     #First, check whether the user is logged in; if not, redirect to login
    if Item.no_empty_params?(params)                                                                        #Sedcond, check whether all form fields are populated; if not, reaload the form
      @item= current_user.items.find_or_create_by(name: params[:name], status: "listing")             #It might be that the user is putting info for a listing that already exiists in the user's listings
      if params[:stock].class == "Integer" && (1..99).include?(params[:stock])                                #Third, if the stock if out of range, reload the form (incalid stock input)
        if @item.user                                                                                     #Fourth, if the current user already has an item whose name matches the params[:name], reload the form
          redirect to "/items/new?error= You already have a listing with that item's name"
        else
          @item.user = current_user
          @item.price = params[:price]
          @item.status = "listing"
          @item.save
          handle_stock
          redirect to "/items/#{@item.id}"
        end
      else
        flash[:message]= "Stock must be between 1 and 99"
        redirect to "/items/new?error= Stock must be between 1 and 99"
      end
    else
      flash[:message]= "All fields must be completed"
      redirect to "/items/new?error= All fields must be completed"
    end
  end

  get '/items/:id' do
    @item= Items.find(params[:id])
    if @item.status == "listing"
      erb :'items/show_item'
    else
      erb :'items/show_item_buy'
    end
  end

  get '/items/:id/edit' do
    @item= Item.find(params[:id])
    erb :'items/edit_item'
  end

  delete '/items/:id' do
    redirect_if_not_logged_in
    @item = Item.find(params[:id])
    if @item.user == current_user
      all_stock= @item.stock
      all_stock.times {
        destroy_item= Item.all.find {|item| item.name == @item.name && item.user == current_user && item.status == "listing"}
        destroy_item.delete
      }
    end
  end

  patch 'items/:id' do
    @item = Item.find(params[:id])
    Item.all.select do |item|
      if item.name == @item.name && item.user == current_user
        item.name = params[:name]
        item.price = params[:price]
        item.save
      end
    end
    @item= Item.all.find {|item| item.name == params[:name] && item.user_id == current_user.id}
    handle_stock
  end


  helpers  do
    def handle_stock
      if params[:stock] > @item.stock
        add_items
      elsif params[:stock] < @item.stock
        subtract_items
      end
    end
   
     def add_items
        add = params[:stock] - @item.stock 
        add.times {
          new_item= Item.new(name: @item.name, price: @item.price, status: "listing")
          new_item.user = current_user
          new_item.save
        }
     end

     def subtract_items
        subtract = @item.stock - params[:stock]
        subtract.times {
          destroy_item= Item.all.find {|item| item.name == params[:name] && item.user == current_user && item.status == "listing"}
          destroy_item.delete
        }
     end

    end


end