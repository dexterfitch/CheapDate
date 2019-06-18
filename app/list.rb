class List < ActiveRecord::Base
  has_many :restaurants
  belongs_to :user
end