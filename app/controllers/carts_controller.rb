class CartsController < ApplicationController

  post '/add_item/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    current_user.cart.items << @item
    erb :'items/items'
  end

  get '/buy/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    current_user.cart.items << @item
    @user= current_user
    erb :'cart/show'
  end

  patch '/carts/:id' do
    @item = Item.find(params[:id])
    @user= current_user
    limit = @item.user.items.select {|i| i.name == @item.name && i.status == "listing"}.count
    if params[:quantity] > limit
      flash[:meesage] = "The seller's limit is #{limit}"
      erb :'carts/show'
    else
      current_quantity = @user.cart.items.select {|i| i.name == @item.name}.count
      new_quantity = param[:quantity] - current_quantity
      if new_quantity > 0
        seller_item_ids= @item.user.items.select {|i| i.name == @item.name && i.status == "listing"}.ids
        user_item_ids= @user.cart.items.select {|i| i.name == @item.name}.ids
        options_ids = seller_item_ids.difference(user_item_ids)
        new_quantity.times{ |i|
            @user.cart.items << Item.find(options_ids[i])
        }
        redirect to '/carts/show'

      elsif new_quantity < 0
        new_quantity = current_quantity - param[:quantity]
        seller_item_ids= @item.user.items.select {|i| i.name == @item.name && i.status == "listing"}.ids
        user_item_ids= @user.cart.items.select {|i| i.name == @item.name}.collect {|i| i.id}
        options_ids = user_item_ids.difference(seller_item_ids)
        binding.pry
        new_quantity.times { |i|
            @user.cart.items.splice(user_item_ids[i], 1)
        }
        redirect to '/carts/show'
      end
    end
  end

end