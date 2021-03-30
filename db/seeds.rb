juan= User.create(:username => "Juan", :email => "juan@hotmail.com", :password => "juan")
rose= User.create(:username => "Rose", :email => "rose@hotmail.com", :password => "rose")
mark= User.create(:username => "Mark", :email => "mark@hotmail.com", :password => "mark")
july= User.create(:username => "July", :email => "july@hotmail.com", :password => "july")
dave= User.create(:username => "Dave", :email => "dave@hotmail.com", :password => "dave")

    iphone6= Item.create(name: "Iphone6", price: 71.28)
    world_languages= Item.create(name: "World Languages", price: 23.00)

    eraser= Item.create(name: "Eraser", price: 3.08)
    notebook= Item.create(name: "Notebook", price: 1.50)

    charger= Item.create(name: "Charger", price: 31.47)
    earphones= Item.create(name: "Earphones", price: 25.99)

    chair= Item.create(name: "Chair", price: 40.39)
    desk= Item.create(name: "Desk", price: 67.99)

    blender= Item.create(name: "Blender", price: 35.50)
    coffe= Item.create(name: "Coffe", price: 6.90)

iphone6.user_id= juan.id
world_languages.user_id= juan.id

eraser.user_id= rose.id
notebook.user_id= rose.id

charger.user_id= mark.id
earphones.user_id= mark.id

chair.user_id= july.id
desk.user_id= july.id

blender.user_id= dave.id
coffe.user_id= dave.id

User.all.each do |user|
  user.funds = 100.00
  user.save
end