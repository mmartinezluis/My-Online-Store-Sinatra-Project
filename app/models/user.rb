class User < ActiveRecord::Base
  validates_presence_of :username, :email, :password
  has_many :items
  has_one :cart
  has_secure_password

  def enough_funds?
    self.funds >= self.cart.total
  end

  def buy
   self.funds = self.funds - self.cart.total
   self.cart.items.each do |item|
    item.user_id = self.id
   end
  end

  def checkout  
    enough_funds?
    buy
  end

end