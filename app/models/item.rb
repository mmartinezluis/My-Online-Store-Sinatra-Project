class Item < ActiveRecord::Base
  validates_presence_of :name, :price
  belongs_to :user


  def stock
    self.class.find {|item| item.name == self.name && item.user_id == current_user.id }.count
    #binding.pry
  end

end

