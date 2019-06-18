class Restaurant
  require 'rest-client'
  require 'pry'

  # JSON Data pull start
  url = "https://developers.zomato.com/api/v2.1/search?lat=47.60952&lon=-122.33573&sort=real_distance&apikey=8ffd293dba7a91cfe9bd20e3da1f4bc1"
  response = RestClient.get(url)
  json = JSON.parse(response)
  @@restaurants = json['restaurants']
  # JSON Data pull end

  @@all = []

  attr_accessor :name, :street_address, :city, :phone, :menu, :rating, :deliveryTF, :couponTF

  def initialize(name, street_address, city, phone, menu, rating, deliveryTF, couponTF)
    @name = name
    @street_address = street_address
    @city = city
    @phone = phone
    @menu = menu
    @rating = rating
    @deliveryTF = deliveryTF
    @couponTF = couponTF
    @@all << self
  end

  def self.get_restaurant
    i = 0
    for each in @@restaurants
      restaurant_data = []
      restaurant_data << @@restaurants[i]["restaurant"]["name"]
      restaurant_data << (@@restaurants[i]["restaurant"]["location"]["address"])[0...-6]
      restaurant_data << @@restaurants[i]["restaurant"]["location"]["city"]
      restaurant_data << @@restaurants[i]["restaurant"]["phone_numbers"]
      restaurant_data << @@restaurants[i]["restaurant"]["menu_url"]
      restaurant_data << @@restaurants[i]["restaurant"]["user_rating"]["aggregate_rating"]
      if @@restaurants[i]["restaurant"]["has_online_delivery"] == 0
        restaurant_data << false
      else
        restaurant_data << true
      end
      restaurant_data << @@restaurants[i]["restaurant"]["include_bogo_offers"]

      Restaurant.new(restaurant_data[0], restaurant_data[1], restaurant_data[2], restaurant_data[3], restaurant_data[4], restaurant_data[5], restaurant_data[6], restaurant_data[7])

      i+= 1
    end
  end

  Restaurant.get_restaurant
end






