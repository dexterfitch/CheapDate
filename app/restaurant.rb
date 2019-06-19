require 'rest-client'
require 'pry'

class Restaurant < ActiveRecord::Base
  has_many :users, through: :restaurants_users
end