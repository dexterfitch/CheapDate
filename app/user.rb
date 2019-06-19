require 'rest-client'
require 'pry'

class User < ActiveRecord::Base
  belongs_to :restaurants_users
  has_many :restaurants, through: :list


# Instance Methods

  ## Users

  # allows user to delete their account
  def delete_user_account
  end


  ## List

  # returns the user's list of saved restaurants
  def my_list
    List.all.select { |each_list| each_list.user_id == self.id }
  end

  # allows user to add a restaurant to their list
  def add_to_list  
  end

  # allows user to remove a restaurant from their list
  def remove_from_list
  end

  # allows user to add a comment/note to a restaurant on their list
  def add_comment
  end

  # allows user to edit an existing comment/note
  def edit_comment
  end

  # allows user to remove a comment/note from a restaurant on their list
  def remove_comment
  end


  ## Restaurant Filter
  # allows user to select only restaurants with online delivery
  def will_deliver
    RestaurantsUser.all.select { |each_ru| each_ru.restaurant.deliveryTF == true}
  end

  # allows user to select only restaurants with coupons/offers
  def even_cheaper_dates
    RestaurantsUser.all.select { |each_ru| each_ru.restaurant.couponTF == true}
  end


  ## Stretch
  # allows user to refine restaurants by cuisine
  # def in_the_mood_for(cuisine)
  # end







  # def self.get_lat(json_data)
  #   @lat = json_data['latt']
  # end

  # def self.get_long(json_data)
  #   @long = json_data['longt']
  # end

  # def self.create_user
  #   user_data = []
  #   puts "Enter a Username"
  #   user_data << STDIN.gets.chomp
  #   puts "Enter your Name"
  #   user_data << STDIN.gets.chomp
  #   puts "Enter your Street"
  #   user_data << STDIN.gets.chomp
  #   puts "Enter your City"
  #   user_data << STDIN.gets.chomp

  #   url = "https://geocode.xyz/#{user_data[2]}, #{user_data[3]}?auth=320648042245458443936x2710&json=1"
  #   clean_url = url.gsub(" ", "%20")
  #   response = RestClient.get(clean_url)
  #   json = JSON.parse(response)

  #   user_data << User.get_lat(json)
  #   user_data << User.get_long(json)

  #   User.new(user_data[0], user_data[1], user_data[2], user_data[3], user_data[4], user_data[5])
  # end

  # User.create_user
end
