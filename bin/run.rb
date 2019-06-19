require_relative '../config/environment'

lets_go = CommandLineInterface.new
lets_go.find_a_cheap_date

User.create_user

puts "Collecting your nearby restaurants...\n\n\n"

Restaurant.pull_restaurant_json
Restaurant.get_restaurant