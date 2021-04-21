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
  
  #####################################################################
  def current_quantity(item)
    self.items.select {|i| i.name == item.name && i.user_id == item.user_id}.count
  end

  def handle_item_add(quantity, item)
    quantity.times {
      self.items << item
      self.save
    }
  end

  def handle_item_subtract(quantity, item)
    new_quantity = (-1) * quantity
    new_quantity.times {
      index = self.items.index {|n| n.id == item.id}
      self.items.slice!(index)
      self.save
    }
  end

  def purchase
    # Debit the buyer and pay the seller(s)
    handle_funds
    # Find the seller items to be purchased and assign those items' user_id to the buyer's user_id
    self.uniq_items.each do |item|                                                  #From the cart, get an array containing items with no repetitions, and select one of such uniq items
      seller_items = item.user.items.select {|i| i.name == item.name}               #Find the seller of my item of interest (above) and collect all of the instances of my item of interes from the seller
      self.item_quantity(item).times {|i|                                           #Quantify the copies of my item of interest currently on my cart (that's how  many instances of that item that I want to buy)
        seller_items[i].status = "purchased"                                        #From the seller available instances, select the first instance, mark it as purchased, and assign the instance to me. Repaat this accoding to the quantity of copies that I want to purchase
        seller_items[i].user = self.user
        seller_items[i].save
      }
    end
    # Empty the cart and save it
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
      total_payemnt = self.item_quantity(item) * item.price
      seller= item.user
      seller.funds += total_payment
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
    self.items.uniq
  end

  def item_quantity(item)
    self.items.select {|i| i.name == item.name && i.user == item.user}.count
  end

end

