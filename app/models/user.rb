# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
	has_many :orders
	has_many :products, through: :orders

	def make_order(product_hash)
		if product_hash.present? and (q = QuadArkopter.reserve).present?  									# should probably block for ready copters move copter bit to sidekiq
			order = self.orders.create(status: "processing", quad_arkopter: q)
			
			# We need to connect all available products to the Order so 
			#Sidekiq doesn't need to serialize all the data, just find the order_id
			product_hash.each do |item_name,quantity|
				begin
					stock_item 			= StockItem.where(name: item_name).take!
					stock_item.products.limit(quantity).update_all(
						order_id: 	order, 
						status: "processing"
					) if stock_item.products.count >= quantity													# earmark for shipping only if we can fulfill a product type in full
				rescue ActiveRecord::RecordNotFound => e
					logger.debug "There are no #{stock_item} products!"
				end
			end
		end
	end
end
