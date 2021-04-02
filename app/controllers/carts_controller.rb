class CartsController < ApplicationController

  get '/add_item/:id' do
    redirect_if_not_logged_in
    @cart= current_user.cart
    @item= Item.find(params[:id])
    @cart.items << @item
    @cart.save
    erb :'items/items'
  end

  get '/buy/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    current_user.cart.items << @item
    @user= current_user
    erb :'cart/show'
  end

  get '/carts/:id' do
    redirect_if_not_logged_in
    @cart= Cart.find(params[:id])
    @user = current_user
    @uniq_items= @cart.uniq_items
    erb :'carts/show'
  end

  patch '/carts/:id' do
    redirect_if_not_logged_in
    @item = Item.find(params[:id])
    @user= current_user
    @cart = current_user.cart
    limit = @item.stock
    if params[:quantity].to_i > limit
      flash[:message] = "The seller's limit is #{limit}"
      redirect to "/carts/#{@cart.id}"
    else
      valid_quantity?
      current_quantity = @cart.items.select {|i| i.name == @item.name}.count
      new_quantity = params[:quantity].to_i - current_quantity
      if new_quantity > 0
        #handle_item_add_update
        new_quantity.times {
            @cart.items << @item
            @cart.save
        }
        flash[:message] = "Item quantity updated"
        redirect to "/carts/#{@cart.id}"
      elsif new_quantity < 0
        #handle_item_add_update
        new_quantity = current_quantity - params[:quantity].to_i
        new_quantity.times {
            index = @cart.items.index {|n| n.id == @item.id}
            @cart.items.slice!(index)
            @cart.save
        }
        flash[:message] = "Item quantity updated"
        redirect to "/carts/#{@cart.id}"
      end
      redirect to "/carts/#{@cart.id}"
    end
  end


  def helpers
    def valid_quantity?
      unless params[:quantity].to_i > 0
        flash[:message] = "Item quantity must be greater than 0"
        redirect to "/carts/#{@cart.id}"
      end
    end
  end

end



   #seller_item_ids= @item.user.items.select {|i| i.name == @item.name && i.status == "listing"}.collect {|i| i.id}
        #user_item_ids= @user.cart.items.select {|i| i.name == @item.name}.collect {|i| i.id}
        #options_ids = seller_item_ids.difference(user_item_ids)


              #seller_item_ids= @item.user.items.select {|i| i.name == @item.name && i.status == "listing"}.collect {|i| i.id}
        #user_item_ids= @user.cart.items.select {|i| i.name == @item.name}.collect {|i| i.id}
        #options_ids = user_item_ids.difference(seller_item_ids)