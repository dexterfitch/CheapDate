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
      if @@cheap_eats[i]["restaurant"]["has_online_delivery"] == 0
        restaurant_data << false
      else
        restaurant_data << true
      end
      restaurant_data << @@cheap_eats[i]["restaurant"]["include_bogo_offers"]
      restaurant_data << @@cheap_eats[i]["restaurant"]["cuisines"]

      Restaurant.create(name: restaurant_data[0], street_address: restaurant_data[1], city: restaurant_data[2], phone: restaurant_data[3], menu: restaurant_data[4], rating: restaurant_data[5], deliveryTF: restaurant_data[6], couponTF: restaurant_data[7], cuisines: restaurant_data[8])

      i+= 1
    end
  end

  def Restaurant.join_users
    Restaurant.all.each { |cheap_eat|
      RestaurantsUser.create(user_id: $current_user.id, restaurant_id: cheap_eat.id)
    }
  end

  def Restaurant.your_cheap_eats
    while true
      puts "What would you like to do now? (List? Help, Exit etc..)"
      answer = STDIN.gets.chomp
      answer = answer.downcase
      case answer
      when "list"
        Restaurant.list_your_eats
      when "cuisine"
        Restaurant.list_cuisines
      when "delivery"
        Restaurant.will_deliver
      when "coupons"
        Restaurant.has_coupons
      when "name sort"
        Restaurant.sort_your_eats_by_name
      when "help"
        puts "Commands:\n > List - Will list all your local Cheap Eats.\n > Cuisine - Will list available cuisines.\n > Name Sort - Will sort your list by name.\n > Delivery - Will list all restaurants offering delivery.\n > Coupons - Will list all restaurants with special offers.\n > Exit - Close the app."
      when "exit"
        puts "Bye!"
        break
      end
    end
  end

  def Restaurant.list_your_eats
    my_cheap_eats = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    my_cheap_eats.each do |cheap_eat|
      this_eat = Restaurant.find(cheap_eat.restaurant_id)
      puts "\n\nName: #{this_eat.name}\nAddress: #{this_eat.street_address}\nPhone Number: #{this_eat.phone}\nMenu: #{this_eat.menu}\nCuisines: #{this_eat.cuisines}\nRating: #{this_eat.rating} | Delivery: #{this_eat.deliveryTF} | Coupons: #{this_eat.couponTF}"
    end
  end

  def Restaurant.sort_your_eats_by_name
    presorted_eats = []
    sorted_eats = []
    my_eats = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    my_eats.each do |eat|
      eat = Restaurant.find(eat.restaurant_id)
      presorted_eats << eat
    end
    sorted_eats = presorted_eats.sort_by { |k| k[:name].downcase }
    sorted_eats.each do |this_eat|
      puts "\n\nName: #{this_eat.name}\nAddress: #{this_eat.street_address}\nPhone Number: #{this_eat.phone}\nMenu: #{this_eat.menu}\nCuisines: #{this_eat.cuisines}\nRating: #{this_eat.rating} | Delivery: #{this_eat.deliveryTF} | Coupons: #{this_eat.couponTF}"
    end
  end

  def Restaurant.list_cuisines
    my_cuisine_choices = []
    my_available_restaurants = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    my_available_restaurants.each do |restaurant_option|
      this_cuisine_choice = Restaurant.find(restaurant_option.restaurant_id)
      my_cuisine_choices << this_cuisine_choice.cuisines
    end
    puts my_cuisine_choices.uniq
  end

  def Restaurant.will_deliver
    my_delivery_options = []
    my_available_restaurants = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    my_available_restaurants.each do |restaurant_option|
      delivers = Restaurant.find(restaurant_option.restaurant_id)
      my_delivery_options << delivers
    end
    
    my_delivery_options.each do |option|
      if option.deliveryTF == true
        puts "\n\nName: #{option.name}\nAddress: #{option.street_address}\nPhone Number: #{option.phone}\nMenu: #{option.menu}\nCuisines: #{option.cuisines}\nRating: #{option.rating} | Coupons: #{option.couponTF}"
      end
    end
  end

   def Restaurant.has_coupons
    my_coupon_options = []
    my_available_restaurants = RestaurantsUser.select { |ru| ru.user_id == $current_user.id }
    my_available_restaurants.each do |restaurant_option|
      coupons = Restaurant.find(restaurant_option.restaurant_id)
      my_coupon_options << coupons
    end
    my_coupon_options.each do |option|
      if option.couponTF == true
        puts "\n\nName: #{option.name}\nAddress: #{option.street_address}\nPhone Number: #{option.phone}\nMenu: #{option.menu}\nCuisines: #{option.cuisines}\nRating: #{option.rating} | Delivery: #{option.deliveryTF}"
      end
    end
  end

end







# when "pick cuisine"
#         Restaurant.list_cuisines
#         puts "\n\nPlease enter a cuisine.\n"
#         choice = STDIN.gets.chomp
#         choice = choice.downcase
#         Restaurant.filter_cuisines(choice)






  # def Restaurant.filter_cuisines(choice)
  #   offers_my_choice = []
  #   my_available_restaurants = RestaurantsUser.select { |ru| ru.user_id == $current_user.id}
  #   my_available_restaurants.each do |restaurant_option|
  #     offers_the_cuisine = Restaurant.find(restaurant_option.restaurant_id) 
  #     offers_my_choice << offers_the_cuisine
  #   end
  #   binding.pry
 
  #  \n > Pick Cuisine - Will let you filter for a particular cuisine.

  # end
