# Name of Class should be restaurants_user

class RestaurantsUser < ActiveRecord::Base
  has_many :restaurants
  has_many :users
end