class Item < ActiveRecord::Base
  validates_presence_of :name, :price
  belongs_to :user

  include Slugifiable::Items
  extend Slugifiable::ClassMethods

  def stock
    #self.class.find {|item| item.name == self.name && item.user_id == current_user.id }.count
    self.user.items.select {|item| item.name == self.name && item.status == "listing" }.count     #Instance method; for a given item, find that item's user, then count the number of items in the user's items array that have the same name as the given item.
  end

  def show_price
    self.price.to_s           #Changes the scientific notation number returnned by .price into a number with two decimal places within a string.
  end

  def self.no_empty_params?(params)
    !params[:name].empty? && !params[:price].empty? && !params[:stock].empty?
  end

end

