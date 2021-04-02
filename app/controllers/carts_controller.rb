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
    @cart = current_user.cart
    @item= Item.find(params[:id])
    @cart.items << @item
    @cart.save
    redirect to "carts/#{@cart.id}"
  end

  get '/carts/:id' do
    redirect_if_not_logged_in
    @cart= Cart.find(params[:id])
    @user = current_user
    cart_owner?
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
      new_quantity = @cart.new_quantity(params)
    #   current_quantity = @cart.items.select {|i| i.name == @item.name}.count
    #   new_quantity = params[:quantity].to_i - current_quantity
      if new_quantity > 0
        @cart.handle_item_add(params)
        # new_quantity.times {
        #     @cart.items << @item
        #     @cart.save
        # }
        flash[:message] = "Item quantity updated"
        redirect to "/carts/#{@cart.id}"
      elsif new_quantity < 0
        @cart.handle_item_subtract(params)
        # new_quantity = current_quantity - params[:quantity].to_i
        # new_quantity.times {
        #     index = @cart.items.index {|n| n.id == @item.id}
        #     @cart.items.slice!(index)
        #     @cart.save
        # }
        flash[:message] = "Item quantity updated"
        redirect to "/carts/#{@cart.id}"
      end
      redirect to "/carts/#{@cart.id}"
    end
  end

  post '/placeorder/:id' do
    redirect_if_not_logged_in
    @user= current_user
    @cart = Cart.find(params[:id])
    # if @cart.over_limit_item?
    #   over_limit_item = @cart.over_limit_item
    #   flash[:message] = "The seller's limit for #{over_limit_item.name} is #{over_limit_item.stock}"
    #   redirect to "/carts/#{@cart.id}"
    # elsif !@cart.enough_funds?
    #   flash[:message] = "You do not have enough funds for this order"
    #   redirect to "/carts/#{@cart.id}"
    # else
      @cart.purchase
    #   flash[:message] = "Your order was successfully processed"
      redirect to "/users/#{@user.slug}"
    # end
  end

  delete '/carts/:id' do
    redirect_if_not_logged_in
    @item= Item.find(params[:id])
    @user= current_user
    @cart= @user.cart
    @cart.items.delete_if {|i| i.id == @item.id}
    @cart.save
    redirect to "/carts/#{@cart.id}"
  end

  helpers  do
    def valid_quantity?
      unless params[:quantity].to_i > 0
        flash[:message] = "Item quantity must be greater than 0"
        redirect to "/carts/#{@cart.id}"
      end
    end

    def cart_owner?
      unless @cart.user == current_user
        flash[:message] = "You cnat only see your own cart"
        redirect to "/items"
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