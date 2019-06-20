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

  # def User.new_user?
  #   puts "Have you used this app before? (y/n)"
  #   answer = STDIN.gets.chomp
  #   if answer.downcase == "y"
  #     puts "Enter your username"
  #     my_un = STDIN.gets.chomp
  #     User.find_user(my_un)
  #   else
  #     User.create_user
  #   end
  # end

  # def User.find_user(un)
  #   un = STDIN.gets.chomp
  #   User.find_by(username: un)
  # end

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
    @@restaurants = []

    while start < 81
      url = "https://developers.zomato.com/api/v2.1/search?start=#{start}&count=20&lat=#{$current_user.lat}&lon=#{$current_user.long}&sort=real_distance&apikey=8ffd293dba7a91cfe9bd20e3da1f4bc1"
      response = RestClient.get(url)
      json = JSON.parse(response)
      @@restaurants << json['restaurants']
      start += 20
    end

    @@restaurants.flatten!
    @@cheap_eats = @@restaurants.select { |restaurant| restaurant["restaurant"]["average_cost_for_two"] <= 30 }
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

      Restaurant.create(name: restaurant_data[0], street_address: restaurant_data[1], city: restaurant_data[2], phone: restaurant_data[3], menu: restaurant_data[4], rating: restaurant_data[5], deliveryTF: restaurant_data[6], couponTF: restaurant_data[7])

      i+= 1
    end
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
