# == Schema Information
#
# Table name: products
#
#  id               :integer          not null, primary key
#  stock_item_id    :integer
#  inventory_name   :string(255)
#  status           :string(255)
#  order_id         :integer
#  quad_arkopter_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

# The Products table is the Inventory of SKUs 
class Product < ActiveRecord::Base
	belongs_to :stock_item
	belongs_to :quad_arkopter
	belongs_to :order


	def set_availabilty_async
		item = self.stock_item
		AbacusNinja.perform_async("set_availabilty",item.name, self.item.quantity) if item.present?
	end

	def get_availabilty_async
		item = self.stock_item
		AbacusNinja.perform_async("get_availabilty",item.name) if item.present?
	end

	# reminder to implement one-off purchases
	def buy
	end
end
