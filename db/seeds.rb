

users_list = [ 
    {:username => "Juan", :email => "juan@hotmail.com", :password => "juan"},
    {:username => "Rose", :email => "rose@hotmail.com", :password => "rose"},
    {:username => "Mark", :email => "mark@hotmail.com", :password => "mark"},
    {:username => "July", :email => "july@hotmail.com", :password => "july"},
    {:username => "Dave", :email => "dave@hotmail.com", :password => "dave"}
]

items_list = [
    {name: "iPhone6", price: 71.28},
    {name: "World Languages", price: 23.00},
    {name: "iPhone6", price: 83.08},
    {name: "Notebook", price: 1.50},
    {name: "Charger", price: 31.47},
    {name: "Earphones", price: 25.99},
    {name: "Chair", price: 40.39},
    {name: "Desk", price: 67.99},
    {name: "Blender", price: 35.50},
    {name: "Blender", price: 35.50}
]

def create_users(array)
  array.each do |user_hash|
    q= User.new
    user_hash.each {|attribute, value| q.send(("#{attribute}="), value)}        # This method can effectively handle the "password" key and "password_digest" key conflict between the Users hash and the ActiveRecord's has_secure_password macro.
    q.funds = 100.00
    q.cart = Cart.new
    q.save
  end
end
  
def create_items(array)
  array.each do |item_hash|
    s = Item.new
    item_hash.each do |key, value|
      s[key] = value
    end
    s.save
  end
  condensed_cascade                
end

def condensed_cascade
  2.times { |i|
    p= User.all[0]                      # Let p be User 1        
    pi= Item.all[i]                     # Let p1 be the first item (Item.all[0]) and let p2 be the second item (Item.all[1]).
    pi.user = p                         # Assign User 1 to both the first item and the second item.
    pi.save                             # Save both items.
                                        
    q= User.all[1]
    qi= Item.all[i+2]
    qi.user = User.all[1]
    qi.save
    
    r= User.all[2]
    ri= Item.all[i+4]
    ri.user = User.all[2]
    ri.save
    
    s= User.all[3]
    si= Item.all[i+6]
    si.user = User.all[3]
    si.save
    
    t= User.all[4]
    ti= Item.all[i+8]
    ti.user = User.all[4]
    ti.save
  }
end
  
create_users(users_list)
create_items(items_list)