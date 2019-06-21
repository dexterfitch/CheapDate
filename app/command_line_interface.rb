require_relative 'list'
require_relative 'restaurant'
require_relative 'restaurants_user'
require_relative 'user'

class CommandLineInterface

  def find_a_cheap_date
    puts "\n\n\nWelcome to 💲 CheapDate 💕, where we specialize in finding cheap eats for two!"
  end

  # USER METHODS

  def existing_user
    puts "Do you have an account already? (y/n)"
    answer = STDIN.gets.chomp
    answer = answer.downcase
    case answer
    when "y"
      puts "What is your username?"
      answer = STDIN.gets.chomp
      if User.find_by(username: answer) == nil
        puts "\n\nUsername does not exist 🙁 Let's create an account!"
        User.create_user
        puts "\n\n\nCollecting your nearby restaurants...  🍽\n\n\n"
        Restaurant.pull_restaurant_json
        Restaurant.get_restaurant
        Restaurant.join_users
        Restaurant.cheap_eats
      else
        $current_user = User.find_by(username: answer)
        puts "\n\n\nWelcome back, #{$current_user.name}"
        puts "\n\n\nCollecting your nearby restaurants...  🍽\n\n\n"
        Restaurant.cheap_eats
      end
    when "n"
      puts "Let's set up your account!\n\n\n"
      User.create_user
      puts "\n\n\nCollecting your nearby restaurants...  🍽\n\n\n"
      Restaurant.pull_restaurant_json
      Restaurant.get_restaurant
      Restaurant.join_users
      Restaurant.cheap_eats
    end
  end

end