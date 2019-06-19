class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :street
      t.string :city
      t.decimal :lat
      t.decimal :long
    end
  end
end
