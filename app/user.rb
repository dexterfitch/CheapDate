require 'rest-client'
require 'pry'

class User < ActiveRecord::Base
  has_many :restaurants, through: :restaurants_users
end