class User < ActiveRecord::Base
  belongs_to :location
  has_many :restaurants, through: :list

  attr_reader :username
  attr_accessor :name, :street, :city, :state, :zip

  def initialize(username, name, street, city, state, zip)
    @username = username
    @name = name
    @street = street
    @city = city
    @state = state
    @zip = zip
  end
end