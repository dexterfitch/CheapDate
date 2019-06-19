class CreateTableLists < ActiveRecord::Migration[5.0]
  def change
    create_table :lists do |t|
      t.integer :user_id
      t.integer :restaurant_id
    end
  end
end