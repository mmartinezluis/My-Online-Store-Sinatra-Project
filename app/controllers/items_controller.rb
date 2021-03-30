class ItemsController < ApplicationController

  get '/items/:id' do
    @item= Items.find(params[:id])
    if @item.status == "listing"
      redirect to '/items/show_item_buy'
    else
      redirec to '/items/show_item'
    end
  end

  patch 'items/:id' do
    @item = Item.find(params[:id])
    Item.all.select do |item|
      if item.name == @item.name && item.user_id == current_user.id
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
          new_item.user_id = current_user.id
          new_item.save
        }
     end

     def subtract_items
        subtract = @item.stock - params[:stock]
        subtract.times {
          destroy_item= Item.all.find {|item| item.name == params[:name] && item.user_id == current_user.id && item.status == "listing"}
          destroy_item.delete
        }
     end

    end


end