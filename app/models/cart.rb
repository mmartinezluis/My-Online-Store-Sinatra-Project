class Cart < ActiveRecord::Base
  belongs_to :user
  serialize :items, Array

  def handle_item_add(params)
    new_quantity(params).times {
      self.items << Item.find(params[:id])
      self.save
    }
  end

  def handle_item_subtract(params)
    new_quantity = (-1) * new_quantity(params)
    new_quantity.times {
      index = self.items.index {|n| n.id == Item.find(params[:id]).id}
      self.items.slice!(index)
      self.save
    }
  end

  def new_quantity(params)
    current_quantity= self.items.select {|item| item.name == Item.find(params[:id]).name}.count
    new_quantity = params[:quantity].to_i - current_quantity
  end

  def purchase
    #Debit the buyer and pay the seller(s)
    handle_funds
    #AFind the seller items to be purchased and assign those items' user_id to the buyer's user_id
    self.uniq_items.each do |item|                                                  #From the cart, get an array containing items with no repetitions, and select one of such uniq items
      seller_items = item.user.items.select {|i| i.name == item.name}               #Find the seller of my item of interest (above) and collect all of the instances of my item of interes from the seller
      self.item_quantity(item).times {|i|                                           #Quantify the copies of my item of interest currently on my cart (that's how  many instances of that item that I want to buy)
        seller_items[i].status = "purchased"                                        #From the seller available instances, select the first instance, mark it as purchased, and assign the instance to me. Repaet this accoding to the quantity of copies that I want to purchase
        seller_items[i].user = self.user
        seller_items[i].save
      }
    end
    #Empty the cart and save it
    self.items.clear
    self.save
  end

  def handle_funds
    amount_charged = self.total
    buyer= self.user
    buyer.funds -= amount_charged
    buyer.save
    pay_sellers
  end

  def pay_sellers
    self.uniq_items.each do |item|
      total = self.item_quantity(item) * item.price
      seller= item.user
      seller.funds += total
      seller.save
    end
  end

  def over_limit_item?
    self.uniq_items.find {|item| item_quantity(item) > item.stock} 
  end

  def enough_funds?
    self.user.funds >= self.user.cart.total
  end
  
  def total
    total = 0
    self.uniq_items.each do |item|
      total += self.item_quantity(item) * item.price
    end
    total
  end

  def uniq_items
    ids = []
    uniq_items = []
    array= self.items
    array.sort.each do |item|
      ids << item.id
    end
    uniq_ids= ids.uniq
    uniq_ids.each do |id|
      uniq_items << Item.find(id)
    end
    ids.clear
    uniq_items
  end

  def item_quantity(item)
    self.items.select {|i| i.name == item.name && i.user == item.user}.count
  end

end

