class AddNormalizedCuisineColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :normalized_cuisines, :string
  end
end
