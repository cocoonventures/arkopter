class AddDeliveryTimeToQuadArkopter < ActiveRecord::Migration
  def change
    add_column :quad_arkopters, :delivery_time, :integer, default: 60
  end
end
