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
#  job_id           :string(255)
#

class Order < ActiveRecord::Base
	belongs_to 	:user
	belongs_to 	:quad_arkopter, autosave: true
	has_many	:products

	include ArkopterOperations::OrderStatus

	def pick_n_pull(product_hash)
	 	logger.debug {"Product Hash: #{product_hash.inspect}\n"}
		if product_hash.present?	
			# We need to connect all available products to the Order so 
			# that background processing doesn't need all the data to serialized 
			# which can quickly add up, instead Sidekiq just needs to find the 
			# order_id
			product_hash.each do |item_name,quantity|											
				begin
					logger.debug {"in:#{item_name} and q:#{quantity}"}
					stock_item 			 = StockItem.where(name: item_name).take!			
					items_in_stock 		 = stock_item.quantity

					# earmark for shipping only if we can fulfill a product type in full 
					if items_in_stock 	>= quantity
						self.transaction do
							# keeping as Arel Relation, db update over memory
							stock_item.products.limit(quantity).update_all(order_id: self.id, status: "processing")
						end
					else
						logger.debug 	"There aren't enough #{item_name}s to fill " 		+
										"#{self.user.name}'s order. #{quantity} requested"	+ 
										" and #{items_in_stock}"
					end
				rescue ActiveRecord::RecordNotFound => e
					logger.debug { "Problem getting #{stock_item} products!" }
				rescue => e
					logger.debug { "Strange problem message: #{e.message}\nBacktrace Begin:\n #{e.backtrace.join("\n")}" }
				else #  safe set inventory
					stock_item.set_inventory(items_in_stock - quantity) 
				end
			end
		end
	end

	# send order to asynchronous ninja to kill it, (but in a good way)
	def fulfill_me
		self.transaction do
			self.job_id = FulfillmentNinja.perform_async(self.id)
			save!
		end
	rescue
		logger.debug 	"Problem saving #{self.job_id} to Order #{self.id}"
	else 
		logger.info 	"Sending Order \##{self.id} over to FulfillmentNinja, cross-fingers!"
	end

	def cancel_me
		TerminatorNinja.perform_async(self.id)
	rescue
		logger.debug 	"Problem canceling Order #{self.id}"
	else 
		logger.info 	"Sending Order \##{self.id} over to TerminatorNinja, to kill it and sibblings (products!)"
	end

	# sets status then trickles order status down to inventory items
	def trickle_down_status(new_status)
		# db locking for the status change
		self.transaction do
			begin
				if valid_status?(new_status)
					self.status = new_status
					save!
					new_status 	= "warehoused" if self.status == "canceled" #if Order if cancel then put products back on the shelf
					self.products.update_all(status: new_status)
				else
					logger.debug 	"Order::trickle_down_updates frustrated, stop sending invalid status names" +
									"you sent #{new_status} which isn't in #{STATUSES.inspect}"
				end
			rescue
				logger.debug		"problem saving status to Order #{self.id}, rolling back"
				raise 				ActiveRecord::Rollback
			ensure					# regardless return status (if failed this is the old one, otherwise the new)
				self.status 		
			end
		end
	end
end



