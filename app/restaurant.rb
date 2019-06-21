require 'rest-client'
require 'pry'

class Restaurant < ActiveRecord::Base
  
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

      Restaurant.where(name: restaurant_data[0], street_address: restaurant_data[1], city: restaurant_data[2], phone: restaurant_data[3], menu: restaurant_data[4], rating: restaurant_data[5], cuisines: restaurant_data[6], normalized_cuisines: "").first_or_create

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
      puts "What would you like to do now?\n(Options: List, Cuisine, Sort, Stars, Account, Exit, Help)"
      answer = STDIN.gets.chomp
      answer = answer.downcase
      case answer
      when "list"
        Restaurant.list_my_eats
      when "cuisine"
        Restaurant.list_cuisines
      when "sort"
        Restaurant.sort_my_eats_by_name
      when "stars"
        Restaurant.sort_my_eats_by_rating
      when "account"
        User.access_account
      when "help"
        puts "Commands:\n > List - Will list all your local Cheap Eats. \n > Cuisine - Will list & filter available cuisines. \n > Sort - Will sort your list by name. \n > Stars - Will filter your list by star rating. \n > Account - Edit your account information.\n > Exit - Close the app."
      when "exit"
        puts "\n\nBye! Bon appetit!\n\n"
        exit
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
      puts "\n🥣\nName: #{cheap_eat.name}\nAddress: #{cheap_eat.street_address}\nPhone Number: #{cheap_eat.phone}\nMenu: #{cheap_eat.menu}\nCuisine: #{cheap_eat.cuisines}\nRating: #{cheap_eat.rating}\n"
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

  def Restaurant.sort_my_eats_by_rating
    collected_eats = Restaurant.my_local_cheap_eats
    puts "Show me restaurants with ratings of at least __ stars. (Enter 1-5)"
    min_rating = STDIN.gets.chomp
    sorted_eats = collected_eats.select { |eat| eat[:rating] >= min_rating }
    if sorted_eats.length == 0
      puts "\n\nNo restaurants meet your rating criteria - try again!\n\n"
    end
    Restaurant.print_my_eats(sorted_eats)
  end

  def Restaurant.list_cuisines
    Restaurant.normalize_cuisines
    cuisine_choices = ""
    collected_eats = Restaurant.my_local_cheap_eats
    collected_eats.each do |cheap_eat|
      cuisine_choices.concat(cheap_eat[:normalized_cuisines])
    end
    array_cuisine_choices = cuisine_choices.split(", ")
    unique_cuisine_choices = array_cuisine_choices.uniq.sort
    puts "\n\nYour local cuisine options:\n\n"
    puts unique_cuisine_choices
    puts "\n\nEnter the cuisine you would like:\n\n"
    chosen_cuisine = STDIN.gets.chomp
    chosen_cuisine_results = Restaurant.my_local_cheap_eats.select { |restaurant| restaurant[:normalized_cuisines].downcase.include? chosen_cuisine.downcase }
    Restaurant.print_my_eats(chosen_cuisine_results)
  end

  def Restaurant.normalize_cuisines
    collected_eats = Restaurant.my_local_cheap_eats
    collected_eats.each do |cheap_eat|
      nca = ""
      if cheap_eat[:cuisines].downcase.include? "american"
        nca.concat("American, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "asian"
        nca.concat("Asian Fusion, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "bakery") || (cheap_eat[:cuisines].downcase.include? "pastry") || (cheap_eat[:cuisines].downcase.include? "pastries")
        nca.concat("Bakery, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "bbq") || (cheap_eat[:cuisines].downcase.include? "barbeque") || (cheap_eat[:cuisines].downcase.include? "bar-b-q") || (cheap_eat[:cuisines].downcase.include? "barbecue") || (cheap_eat[:cuisines].downcase.include? "b-b-q")
        nca.concat("BBQ, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "bubble") || (cheap_eat[:cuisines].downcase.include? "boba")
        nca.concat("Bubble/Boba Tea, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "burger"
        nca.concat("Burgers, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "cafe") || (cheap_eat[:cuisines].downcase.include? "coffee") || (cheap_eat[:cuisines].downcase.include? "tea")
        nca.concat("Cafe, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "chinese"
        nca.concat("Chinese, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "columbi"
        nca.concat("Colombian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "deli"
        nca.concat("Deli, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "dessert") || (cheap_eat[:cuisines].downcase.include? "crepe")
        nca.concat("Desserts, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "dim"
        nca.concat("Dim Sum, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "diner"
        nca.concat("Diner, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "donut"
        nca.concat("Donuts, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "drink") || (cheap_eat[:cuisines].downcase.include? "beverage") || (cheap_eat[:cuisines].downcase.include? "juice")
        nca.concat("Drinks, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "fast"
        nca.concat("Fast Food, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "filipino"
        nca.concat("Filipino, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "french"
        nca.concat("French, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "frozen yo") || (cheap_eat[:cuisines].downcase.include? "froyo") || (cheap_eat[:cuisines].downcase.include? "fro yo") || (cheap_eat[:cuisines].downcase.include? "fro-yo")
        nca.concat("Frozen Yogurt, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "fusion"
        nca.concat("Fusion, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "german"
        nca.concat("German, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "greek"
        nca.concat("Greek, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "hawaiian"
        nca.concat("Hawaiian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "health"
        nca.concat("Healthy, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "ice cream") || (cheap_eat[:cuisines].downcase.include? "gelato")
        nca.concat("Ice Cream, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "indian"
        nca.concat("Indian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "israel"
        nca.concat("Israeli, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "italian"
        nca.concat("Italian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "japanese"
        nca.concat("Japanese, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "korean"
        nca.concat("Korean, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "latin"
        nca.concat("Latin American, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "medit"
        nca.concat("Mediterranean, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "pakistan"
        nca.concat("Pakistani, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "peru"
        nca.concat("Peruvian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "pho"
        nca.concat("Pho, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "pizza"
        nca.concat("Pizza, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "pub") || (cheap_eat[:cuisines].downcase.include? "bar")
        nca.concat("Pub, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "mexican"
        nca.concat("Mexican, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "sandwich") || (cheap_eat[:cuisines].downcase.include? "sub") || (cheap_eat[:cuisines].downcase.include? "wrap")
        nca.concat("Sandwiches, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "seafood"
        nca.concat("Seafood, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "sushi") || (cheap_eat[:cuisines].downcase.include? "sashimi")
        nca.concat("Sushi, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "taco"
        nca.concat("Taco, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "tex"
        nca.concat("Tex-Mex, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "thai"
        nca.concat("Thai, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if (cheap_eat[:cuisines].downcase.include? "vegetarian") || (cheap_eat[:cuisines].downcase.include? "vegan") || (cheap_eat[:cuisines].downcase.include? "salad")
        nca.concat("Vegetarian, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
      if cheap_eat[:cuisines].downcase.include? "vietnamese"
        nca.concat("Vietnamese, ")
        cheap_eat.update(normalized_cuisines: nca)
      end
    end
  end
end