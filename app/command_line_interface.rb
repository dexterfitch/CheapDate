require_relative 'list'
require_relative 'restaurant'
require_relative 'restaurants_user'
require_relative 'user'

class CommandLineInterface

  def find_a_cheap_date
    puts "Welcome to CheapDate, where we specialize in finding cheap eats for two!"
    puts "Let's get your account set up."
    
  end

  # def User.get_lat(json_data)
  #   @lat = json_data['latt']
  # end

  # def User.get_long(json_data)
  #   @long = json_data['longt']
  # end

  # def User.create_user
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
  #   User.create_user

end