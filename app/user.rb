class User
  require 'rest-client'
  require 'pry'

  @@all = []

  attr_reader :username
  attr_accessor :name, :street, :city, :lat, :long

  def initialize(username, name, street, city, lat, long)
    @username = username
    @name = name
    @street = street
    @city = city
    @lat = lat
    @long = long
    @@all << self
  end

  def self.get_lat(json_data)
    @lat = json_data['latt']
  end

  def self.get_long(json_data)
    @long = json_data['longt']
  end

  def self.create_user
    user_data = []
    puts "Enter a Username"
    user_data << gets.chomp
    puts "Enter your Name"
    user_data << gets.chomp
    puts "Enter your Street"
    user_data << gets.chomp
    puts "Enter your City"
    user_data << gets.chomp

    url = "https://geocode.xyz/#{user_data[2]}, #{user_data[3]}?auth=320648042245458443936x2710&json=1"
    clean_url = url.gsub(" ", "%20")
    response = RestClient.get(clean_url)
    json = JSON.parse(response)

    user_data << User.get_lat(json)
    user_data << User.get_long(json)

    # User.new(user_data[0], user_data[1], user_data[2], user_data[3], user_data[4], user_data[5])
    User.new(user_data[0], user_data[1], user_data[2], user_data[3], user_data[4], user_data[5])
  end

  User.create_user
end
