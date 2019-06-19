class Restaurant < ActiveRecord::Base
  belongs_to :restaurants_users
  has_many :restaurants, through: :list

  require 'rest-client'
  require 'pry'

  # JSON Data pull start
  start = 0
  @@restaurants = []

  while start < 81
    url = "https://developers.zomato.com/api/v2.1/search?start=#{start}&count=20&lat=47.60952&lon=-122.33573&sort=real_distance&apikey=8ffd293dba7a91cfe9bd20e3da1f4bc1"
    response = RestClient.get(url)
    json = JSON.parse(response)
    @@restaurants << json['restaurants']
    start += 20
  end

  @@restaurants.flatten!
  @@cheap_eats = @@restaurants.select { |restaurant| restaurant["restaurant"]["average_cost_for_two"] <= 30 }
  # JSON Data pull end

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
  end

  # def self.get_restaurant
  #   i = 0

  #   for each in @@cheap_eats
  #     restaurant_data = []
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["name"]
  #     restaurant_data << (@@cheap_eats[i]["restaurant"]["location"]["address"])[0...-6]
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["location"]["city"]
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["phone_numbers"]
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["menu_url"]
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["user_rating"]["aggregate_rating"]
  #     if @@cheap_eats[i]["restaurant"]["has_online_delivery"] == 0
  #       restaurant_data << false
  #     else
  #       restaurant_data << true
  #     end
  #     restaurant_data << @@cheap_eats[i]["restaurant"]["include_bogo_offers"]

  #     new_restaurant = Restaurant.new(restaurant_data[0], restaurant_data[1], restaurant_data[2], restaurant_data[3], restaurant_data[4], restaurant_data[5], restaurant_data[6], restaurant_data[7])
  #     new_restaurant.save

  #     i+= 1
  #   end
  # end

  # Restaurant.get_restaurant
end





