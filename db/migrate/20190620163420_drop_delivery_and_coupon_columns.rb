class DropDeliveryAndCouponColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :restaurants, :deliveryTF
    remove_column :restaurants, :couponTF
  end
end
