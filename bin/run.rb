require_relative '../config/environment'

lets_go = CommandLineInterface.new
lets_go.find_a_cheap_date

User.create_user

puts "\n\n\nCollecting your nearby restaurants...\n\n\n"

Restaurant.pull_restaurant_json
Restaurant.get_restaurant
Restaurant.join_users
Restaurant.your_cheap_eats