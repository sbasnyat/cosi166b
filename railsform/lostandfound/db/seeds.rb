# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'

puts  "Creating Types"
Type.destroy_all

book = Type.create(title: "Book", description: "Textbooks, Novels, etc" )
clothing = Type.create(title: "Clothing", description: "Dresses, Pants, etc" )
cellphone = Type.create(title: "Cellphone", description: "Iphones, Androids, etc" )
computer = Type.create(title: "Computer", description: "Desktops, Laptops, Macs, PCs, etc" )

colors = ["red", "brown", "green", "white"]
phonenames = ["iphone", "nokia", "samsung"]


Item.destroy_all
puts "Creating book"
1.upto(5) do |i|
	Item.create(title: Faker::Lorem.word ,description: Faker::Lorem.sentence, owner: Faker::Name.name, type_id: book.id)
end

puts "Creating clothing"
1.upto(5) do |i|
	Item.create(title: Faker::Commerce.product_name ,description: Faker::Lorem.sentence, owner: Faker::Name.name, type_id: clothing.id)
end

puts "Creating cellphone"
1.upto(5) do |i|
	Item.create(title: Faker::Lorem.word ,description: Faker::Lorem.sentence, owner: Faker::Name.name, type_id: cellphone.id)
end


puts "Creating computer"
1.upto(5) do |i|
	Item.create(title: Faker::Lorem.word ,description: Faker::Lorem.sentence, owner: Faker::Name.name, type_id: computer.id)
end
