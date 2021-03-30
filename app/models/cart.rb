class Cart < ActiveRecord::Base
  belongs_to :user
  @@items =[]

  def self.items
    @@items
  end

  def self.total
   total = 0
   @@items.each do |item|
    total += item.price
   end
   total
  end

end