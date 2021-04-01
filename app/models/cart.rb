class Cart < ActiveRecord::Base
  belongs_to :user
  @@items =[]

  def self.items
    @@items
    #binding.pry
  end

  def self.no_repeat
    no_repeat= []
    @@items.sort do |a,b|
      a.name <=> b.name
    end
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

 