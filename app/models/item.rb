class Item < ActiveRecord::Base
  validates_presence_of :name, :price
  belongs_to :user


  def self.stock(item_name)
    self.find {|item| item.name == item_name}.count
    binding.pry
  end

end