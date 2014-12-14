# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  status           :string(255)
#  user_id          :integer
#  quad_arkopter_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Order < ActiveRecord::Base
	belongs_to :user
	belongs_to :quad_arkopter

	include ArkopterOperations::Status

	def pick_n_pull(product_hash)
		if product_hash.present? #and (q = QuadArkopter.reserve).present?  						# should probably block for ready copters move copter bit to sidekiq
			# We need to connect all available products to the Order so 
			# that background processing doesn't need all the data to serialized 
			# which can quickly add up, instead Sidekiq just needs to find the 
			# order_id
			product_hash.each do |item_name,quantity|
				begin
					stock_item 			 = StockItem.where(name: item_name).take!				#
					items_in_stock 		 = stock_item.products.count
					if items_in_stock 	>= quantity												# earmark for shipping only if we can fulfill a product type in full TODO: push to async ninja
						trickle_down_updates("processing")
					else
						logger.debug 	"There aren't enough #{item_name}s to fill " 	+
										"#{self.user.name}'s order. #{quantity} requested"	+ 
										" and #{items_in_stock}"
					end
				rescue ActiveRecord::RecordNotFound => e
					logger.debug "There are no #{stock_item} products!"
				end
			end
		end
	end

	# send order to asynchronous ninja to kill it, (but in a good way)
	def fulfill_me
		FulfillmentNinja.perform_async(self.id)
		logger.info "Sending Order \##{self.id} over to FulfillmentNinja, cross-fingers!"
	end

	# trickles order status down to inventory items and if 
	# item isn't associated with an order, becomes part of the fam
	def trickle_down_updates(new_status)
		# opting to update_all instead of status= here
		# keeping as Arel Relation makes this a db function update 
		# and not app memory 
		if valid_status?(new_status) 									# conditional on validity since circumventing status= alert
			stock_item.products.limit(quantity).update_all(				# in the future this should maybe use transaction blocks
				order_id: 		self.id, 								# locking the row and rolling back upon exception. Not yet	
				status: 		new_status								#
			) 
		else
			logger.debug 	"Order::trickle_down_updates frustrated, stop sending invalid status names" +
							"you sent #{new_status} which isn't in #{STATUSES.inspect}"
		end
	end
end



