class Restaurant < ActiveRecord::Base
  belongs_to :location
  has_one :user, through: :list

  url = "https://developers.zomato.com/api/v2.1/search?lat=47.60952&lon=-122.33573&sort=real_distance&user-key=8ffd293dba7a91cfe9bd20e3da1f4bc1"
  response = RestClient.get(url)
  json = JSON.parse(response)

  # def initialize(name, city)
  #   @name = name
  #   @city = city
  # end

end