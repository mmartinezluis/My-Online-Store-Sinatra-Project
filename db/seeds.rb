#Method 1
# juan= User.create(:username => "Juan", :email => "juan@hotmail.com", :password => "juan")
# rose= User.create(:username => "Rose", :email => "rose@hotmail.com", :password => "rose")
# mark= User.create(:username => "Mark", :email => "mark@hotmail.com", :password => "mark")
# july= User.create(:username => "July", :email => "july@hotmail.com", :password => "july")
# dave= User.create(:username => "Dave", :email => "dave@hotmail.com", :password => "dave")

#     iphone6= Item.create(name: "Iphone6", price: 71.28)
#     world_languages= Item.create(name: "World Languages", price: 23.00)

#     eraser= Item.create(name: "Eraser", price: 3.08)
#     notebook= Item.create(name: "Notebook", price: 1.50)

#     charger= Item.create(name: "Charger", price: 31.47)
#     earphones= Item.create(name: "Earphones", price: 25.99)

#     chair= Item.create(name: "Chair", price: 40.39)
#     desk= Item.create(name: "Desk", price: 67.99)

#     blender= Item.create(name: "Blender", price: 35.50)
#     coffe= Item.create(name: "Coffe", price: 6.90)

def condensed_cascade
  2.times { |i|
    p= User.all[0]
    pi= Item.all[i]
    pi.user = p
    pi.status = "listing"
    pi.save
    p.funds = 100.00
    p.save

    q= User.all[1]
    qi= Item.all[i+2]
    qi.user = User.all[1]
    qi.status = "listing"
    qi.save
    q.funds = 100.00
    q.save

    r= User.all[2]
    ri= Item.all[i+4]
    riuser = User.all[2]
    ri.status = "listing"
    ri.save
    r.funds = 100.00
    r.save

    s= User.all[3]
    si= Item.all[i+6]
    si.user = User.all[3]
    si.status = "listing"
    si.save
    s.funds = 100.00
    s.save

    t= User.all[4]
    ti= Item.all[i+8]
    ti.user = User.all[4]
    ti.status = "listing"
    ti.save
    t.funds = 100.00
    t.save
  }
end
  
#condensed_cascade


#Method 2
users_list = [
    {:username => "Juan", :email => "juan@hotmail.com", password_digest: "juan"},
    {:username => "Rose", :email => "rose@hotmail.com", password_digest: "rose"},
    {:username => "Mark", :email => "mark@hotmail.com", password_digest: "mark"},
    {:username => "July", :email => "july@hotmail.com", password_digest: "july"},
    {:username => "Dave", :email => "dave@hotmail.com", password_digest: "dave"}
]

items_list = [
    {name: "Iphone6", price: 71.28},
    {name: "World Languages", price: 23.00},
    {name: "Eraser", price: 3.08},
    {name: "Notebook", price: 1.50},
    {name: "Charger", price: 31.47},
    {name: "Earphones", price: 25.99},
    {name: "Chair", price: 40.39},
    {name: "Desk", price: 67.99},
    {name: "Blender", price: 35.50},
    {name: "Coffe", price: 6.90}
]

def create_users(array)
  array.each do |user_hash|
    q= User.new
    #binding.pry
    user_hash.each {|attribute, value| q.send(("#{attribute}="), value)}
    #user_hash.each do |key, value|
      #puts "#{key}, #{value}"
      #q[key] = value
    #end
    q.funds = 100.00
    q.save
  end
end

# def create_users(array)
#   array.each do |user_hash|
#     q= User.new
#     user_hash.each do |attribute, value|
#       q.attribute = value
#     end
#     q.funds = 100.00
#     q.save
#   end
# end

def create_items(array)
  array.each do |item_hash|
    s = Item.new
    #binding.pry
    #item_hash.each {|attribute, value| s.send(("#{attribute}="), value)}
     item_hash.each do |key, value|
      s[key] = value
    end
    s.status = "listing"
    s.save
  end
end

create_users(users_list)
create_items(items_list)