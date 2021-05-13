class CartsController < ApplicationController

  get '/add_item/:id' do
    @cart= current_user.cart
    @item= Item.find(params[:id])
    @cart.items << @item
    @cart.save
    erb :'items/index'
  end

  get '/buy/:id' do
    @cart = current_user.cart
    @item= Item.find(params[:id])
    @cart.items << @item
    @cart.save
    redirect to "carts/#{@cart.id}"
  end

  get '/carts/:id' do
    authorized_cart_view?                 # Defined in applciation controller
    @cart= Cart.find(params[:id])
    @user = current_user
    @uniq_items= @cart.uniq_items
    erb :'carts/show'
  end
  
  # UPDATE action for cart model
  patch '/carts/:id' do
    @cart = current_user.cart
    @item= @cart.items.find { |i| i.id == params[:id].to_i }
    unless @item.stock > 0
      flash[:message] = ["That item is currently out of stock"]
      redirect to "/carts/#{@cart.id}"
    end
    limit = @item.stock
    if params[:quantity].to_i > limit
      flash[:message] = ["The seller's limit for #{@item.name} is #{limit}"]
      redirect to "/carts/#{@cart.id}"
    else
      valid_quantity?
      new_quantity = params[:quantity].to_i - @cart.current_quantity(@item)
      if new_quantity > 0
        @cart.handle_item_add(new_quantity, @item)
        flash[:message] = ["Item quantity updated"]
      elsif new_quantity < 0
        @cart.handle_item_subtract(new_quantity, @item)
        flash[:message] = ["Item quantity updated"]
      end
      redirect to "/carts/#{@cart.id}"
    end
  end

  post '/placeorder/:id' do
    @user= current_user
    @cart = Cart.find(params[:id])
    if @cart.out_of_stock_items != []
      out_of_stock_items = @cart.out_of_stock_items
      flash[:message] = ["Unable to place your order: the item '#{out_of_stock_items[0].name}' is currently out of stock"]
      redirect to "/carts/#{@cart.id}"
    elsif @cart.over_limit_item?
      over_limit_item = @cart.over_limit_item?
      flash[:message] = ["The seller's limit for #{over_limit_item.name} is #{over_limit_item.stock}"]
      redirect to "/carts/#{@cart.id}"
    elsif !@cart.enough_funds?
      flash[:message] = ["You do not have enough funds for this order"]
      redirect to "/carts/#{@cart.id}"
    else
      @cart.purchase
      flash[:message] = ["Your order was successfully processed"]
      redirect to "/users/#{@user.slug}"
    end
  end

  delete '/carts/:id' do
    @cart= current_user.cart
    @item= @cart.items.find { |i| i.id == params[:id].to_i }
    @cart.items.delete_if {|i| i.id == @item.id}
    @cart.save
    redirect to "/carts/#{@cart.id}"
  end

  helpers  do
    def valid_quantity?
      unless params[:quantity].to_i > 0
        flash[:message] = ["Item quantity must be greater than 0"]
        redirect to "/carts/#{@cart.id}"
      end
    end
  end

end
