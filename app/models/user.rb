class User < ActiveRecord::Base
  validates_presence_of :username, :email, :password
  has_secure_password
  validates :username, uniqueness: true
  
  has_many :items
  has_one :cart
  
  #validates :email, uniqueness: true

  include Slugifiable::Users
  extend Slugifiable::ClassMethods

  def show_funds
    self.funds.to_s
  end

  def single_user_listings
    names = []
    listings = []
    self.items.each do |item|  
      if item.status == "listing"
        names << item.name
      end
    end
    uniq_items = names.uniq
    uniq_items.count.times { |i|
      listings << self.items.find {|item| item.name == uniq_items[i]}
    }
    names.clear
    listings
  end

  def self.all_users_listings
    names = []
    listings = []
    User.all.each do |user|
      user.items.each do |item|  
        if item.status == "listing"
          names << item.name
        end
      end
      uniq_items = names.uniq
      uniq_items.count.times { |i|
        listings << user.items.find {|item| item.name == uniq_items[i]}
      }
      names.clear
    end
    listings
  end
  

end