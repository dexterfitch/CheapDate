# require_relative '../app/user'
puts 'here'
# aa = User.new("Cody")

aa = User.create(name:"Fitz McGimly",username:"abseattle", street:"1545 NW Market St", city:"Seattle", lat: 47.6684318, long: -122.3802837)
binding.pry
# User.create("hapster", "Casey Fitch", "7766 Sauerbacker Rd", "Pasadena", 39.1429887, -76.5536976)
# User.create("riopup", "David Wilbert", "2203 Greenough Ct W", "Missoula", 46.8835989, -113.9791414)
# User.create("nagoyatuna", "Linda Breadbutter", "3 Chome-24-4 Nishiki", "Nagoya", 35.169422, 13.9040417)
# User.create("londonbridge", "Jemma Stafford", "67 Lisson St", "London", 51.5211047, -0.1703276)