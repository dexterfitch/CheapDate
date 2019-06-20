class AddCuisinesColumnToRestaurants < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :cuisines, :string
  end
end
