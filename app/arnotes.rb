# Restaurant
< ActiveRecord::Base
  belongs_to :location
  has_one :user, through: :list

# Users
< ActiveRecord::Base
  belongs_to :location
  has_many :restaurants, through: :list


# Location
< ActiveRecord::Base
  has_many :restaurants
  has_many :users