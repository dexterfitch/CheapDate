require_relative 'list'
require_relative 'restaurant'
require_relative 'restaurants_user'
require_relative 'user'

class CommandLineInterface

  def find_a_cheap_date
    puts "\n\n\nWelcome to CheapDate, where we specialize in finding cheap eats for two!"
    puts "Let's get your account set up.\n\n\n"
  end

  def User.get_lat(json_data)
    @lat = json_data['latt']
  end

  def User.get_long(json_data)
    @long = json_data['longt']
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

    url = "https://geocode.xyz/#{user_data[2]}, #{user_data[3]}?auth=320648042245458443936x2710&json=1"
    clean_url = url.gsub(" ", "%20")
    response = RestClient.get(clean_url)
    json = JSON.parse(response)

    user_data << User.get_lat(json)
    user_data << User.get_long(json)

    $current_user = User.new(username: user_data[0], name: user_data[1], street: user_data[2], city: user_data[3], lat: user_data[4], long: user_data[5])
    
    $current_user.save
  end

  def Restaurant.pull_restaurant_json
    start = 0
    restaurants = []

    while start < 81
      url = "https://developers.zomato.com/api/v2.1/search?start=#{start}&count=20&lat=#{$current_user.lat}&lon=#{$current_user.long}&sort=real_distance&apikey=8ffd293dba7a91cfe9bd20e3da1f4bc1"
      response = RestClient.get(url)
      json = JSON.parse(response)
      restaurants << json['restaurants']
      start += 20
    end

    restaurants.flatten!
    @@cheap_eats = restaurants.select { |restaurant| restaurant["restaurant"]["average_cost_for_two"] <= 30 }
  end

  def Restaurant.get_restaurant
    i = 0

    for each in @@cheap_eats
      restaurant_data = []
      restaurant_data << @@cheap_eats[i]["restaurant"]["name"]
      restaurant_data << (@@cheap_eats[i]["restaurant"]["location"]["address"])[0...-6]
      restaurant_data << @@cheap_eats[i]["restaurant"]["location"]["city"]
      restaurant_data << @@cheap_eats[i]["restaurant"]["phone_numbers"]
      restaurant_data << @@cheap_eats[i]["restaurant"]["menu_url"]
      restaurant_data << @@cheap_eats[i]["restaurant"]["user_rating"]["aggregate_rating"]
      restaurant_data << @@cheap_eats[i]["restaurant"]["cuisines"]

      Restaurant.create(name: restaurant_data[0], street_address: restaurant_data[1], city: restaurant_data[2], phone: restaurant_data[3], menu: restaurant_data[4], rating: restaurant_data[5], cuisines: restaurant_data[6])

      i+= 1
    end
  end

  def Restaurant.join_users
    Restaurant.all.each { |cheap_eat|
      RestaurantsUser.create(user_id: $current_user.id, restaurant_id: cheap_eat.id)
    }
  end

  def Restaurant.cheap_eats
    while true
      puts "What would you like to do now?\n(Options: List, Cuisine, Sort, Exit, Help)"
      answer = STDIN.gets.chomp
      answer = answer.downcase
      case answer
      when "list"
        Restaurant.list_my_eats
      when "cuisine"
        Restaurant.list_cuisines
      when "sort"
        Restaurant.sort_my_eats_by_name
      when "help"
        puts "Commands:\n > List - Will list all your local Cheap Eats. \n > Cuisine - Will list available cuisines, and let you select one to filter results. \n > Sort - Will sort your list by name. \n > Exit - Close the app."
      when "exit"
        puts "\n\nBye! Bon appetit!\n\n"
        break
      end
    end
  end

  def Restaurant.my_local_cheap_eats
    collection = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    Restaurant.collect_my_eats(collection)
  end

  def Restaurant.collect_my_eats(restaurant_collection)
    collected_eats = []
    restaurant_collection.each do |cheap_eat|
      collected_eats << Restaurant.find(cheap_eat.restaurant_id)
    end
    collected_eats
  end

  def Restaurant.print_my_eats(restaurant_array)
    restaurant_array.each do |cheap_eat|
      puts "\nName: #{cheap_eat.name}\nAddress: #{cheap_eat.street_address}\nPhone Number: #{cheap_eat.phone}\nMenu: #{cheap_eat.menu}\nCuisine: #{cheap_eat.cuisines}\nRating: #{cheap_eat.rating}\n"
    end
  end

  def Restaurant.list_my_eats
    collected_eats = Restaurant.my_local_cheap_eats
    Restaurant.print_my_eats(collected_eats)
  end

  def Restaurant.sort_my_eats_by_name
    collected_eats = Restaurant.my_local_cheap_eats
    sorted_eats = collected_eats.sort_by { |k| k[:name].downcase }
    Restaurant.print_my_eats(sorted_eats)
  end

  def Restaurant.gather_cuisines
    cuisine_choices = []
    collected_eats = Restaurant.my_local_cheap_eats
    collected_eats.each do |cheap_eat|
      cuisine_choices << cheap_eat.cuisines
    end
    cuisine_choices.uniq
  end

  def Restaurant.normalizew_cuisines
    cuisine_types = [
      "American",
      "Asian Fusion",
      "Bakery",
      "BBQ",
      "Bubble/Boba Tea",
      "Burgers",
      "Cafe",
      "Chinese",
      "Deli",
      "Desserts",
      "Dim Sum",
      "Diner",
      "Donuts",
      "Drinks",
      "Fast Food",
      "Filipino",
      "French",
      "Frozen Yogurt",
      "Greek",
      "Hawaiian",
      "Healthy",
      "Ice Cream",
      "Indian",
      "Italian",
      "Japanese",
      "Korean",
      "Latin American",
      "Pakistani",
      "Pizza",
      "Pub",
      "Mexican",
      "Sandwiches",
      "Seafood",
      "Sushi",
      "Tex-Mex",
      "Thai",
      "Vegetarian",
      "Vietnamese"
    ]
    cuisine_choices = Restaurant.gather_cuisines
    cuisine_choices
end







# when "pick cuisine"
#         Restaurant.list_cuisines
#         puts "\n\nPlease enter a cuisine.\n"
#         choice = STDIN.gets.chomp
#         choice = choice.downcase
#         Restaurant.filter_cuisines(choice)






  # def Restaurant.filter_cuisines(choice)
  #   offers_my_choice = []
  #   my_cheap_eats = RestaurantsUser.select { |ru| ru.user_id == $current_user.id}
  #   my_cheap_eats.each do |restaurant_option|
  #     offers_the_cuisine = Restaurant.find(restaurant_option.restaurant_id) 
  #     offers_my_choice << offers_the_cuisine
  #   end
  #   binding.pry
 
  #  \n > Pick Cuisine - Will let you filter for a particular cuisine.

  # end
