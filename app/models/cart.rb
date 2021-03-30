class Cart < ActiveRecord::Base
  belongs_to :user
  @@items =[]

  def self.items
    @@items
    #binding.pry
  end

  # def self.total
  #  total = 0
  #  @@items.each do |item|
  #   total += item.price
  #  end
  #  total
  #  binding.pry
  # end

end

 Cart.items