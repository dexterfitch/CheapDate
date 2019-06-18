class Location < ActiveRecord::Base
  has_many :restaurants
  has_many :users
  
  attr_reader :city

  def initialize(city)
    @city = city
  end
end