class CreateRestaurants < ActiveRecord::Migration[5.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :street_address
      t.string :city
      t.string :phone
      t.string :menu
      t.string :rating
      t.boolean :deliveryTF
      t.boolean :couponTF
    end
  end
end
