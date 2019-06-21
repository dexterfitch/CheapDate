require 'rest-client'
require 'pry'

class User < ActiveRecord::Base

  def User.get_json
    url = "https://geocode.xyz/#{$current_user[:street]}, #{$current_user[:city]}?auth=320648042245458443936x2710&json=1"
    clean_url = url.gsub(" ", "%20")
    response = RestClient.get(clean_url)
    json = JSON.parse(response)
    json
  end

  def User.create_user
    user_data = []

    puts "Enter a Username"
    user_data << STDIN.gets.chomp    
    puts "Enter your Name"
    user_data << STDIN.gets.chomp
    puts "Enter your Street"
    user_data << STDIN.gets.chomp
    puts "Enter your City"
    user_data << STDIN.gets.chomp
    puts "\n\n\nPlease wait a moment while we look you up..."

    $current_user = User.new(username: user_data[0], name: user_data[1], street: user_data[2], city: user_data[3], lat: 0, long: 0)
    
    $current_user.save

    $current_user.update(lat: User.get_lat(User.get_json))
    $current_user.update(long: User.get_long(User.get_json))
  end

  def User.access_account
    puts "\n\nModify your account?\n(Name, Address, Delete, Return, Help)"
    answer = STDIN.gets.chomp
    answer = answer.downcase
    case answer
    when "name"
      User.edit_name
    when "address"
      User.edit_address
    when "delete"
      User.delete_account
    when "help"
      puts "Commands:\n > Name - Edit your name.\n > Address - Edit your address.\n > Delete - Delete your CheapDate account.\n > Return - Back to the Main Menu."
    when "return"
      Restaurant.cheap_eats
    end
  end

  def User.edit_name
    puts "\n\nThe name currently associated with you account is:\n #{$current_user.name}\n Would you like to change it? (y/n)"
    answer = STDIN.gets.chomp
    answer = answer.downcase
    case answer
    when "y"
      puts "\n\nPlease type the name you would like associated with your account."
      answer = STDIN.gets.chomp
      $current_user.update(name: answer)
      puts "\n\nThank you. Your name has been successfully updated to: #{$current_user.name}\n\n\n\n"
    when "n"
      User.access_account
    end
  end

  def User.edit_address
    puts "\n\nThe address currently associated with you account is:\n #{$current_user.street}, #{$current_user.city}.\n Would you like to change it? (y/n)"
    answer = STDIN.gets.chomp
    answer = answer.downcase
    case answer
    when "y" 
      puts "\n\nPlease enter the street address you'd like to associate with your account: "
      answer = STDIN.gets.chomp
      $current_user.update(street: answer)
      puts "\n\nPlease enter the city you'd like to associate with your account:"
      answer = STDIN.gets.chomp
      $current_user.update(city: answer)
      puts "\n\nThank you, your account has been updated. Your address is:\n #{$current_user.street}, #{$current_user.city}"
      puts "\n\nPlease wait a moment while we get your new restaurants...  🍽️\n\n"
      RestaurantsUser.where(:user_id == $current_user.id).destroy_all
      $current_user.update(lat: User.get_lat(User.get_json))
      $current_user.update(long: User.get_long(User.get_json))
      Restaurant.pull_restaurant_json
      Restaurant.get_restaurant
      Restaurant.join_users
      Restaurant.cheap_eats
    when "n"
      User.access_account
    end
  end

  def User.delete_account
    puts "Please enter your username to delete your account."
    answer = STDIN.gets.chomp
    User.where(:username => answer).destroy_all
    puts "\n\nWe're sorry to see you go. Remember, you can always rejoin us and create a new account!"
    exit
  end

  def User.get_lat(json_data)
    @lat = json_data['latt']
  end

  def User.get_long(json_data)
    @long = json_data['longt']
  end
end