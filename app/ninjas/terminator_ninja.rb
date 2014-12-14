# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

class TerminatorNinja

	include Sidekiq::Worker

	sidekiq_options queue: "terminator", backtrace: true
	sidekiq_options retry: true

	def perform(order_id)
		@order 		= Order.find(order_id)
		@arkopter 	= QuadArkopter.find(@order.) if @order.present?
	rescue ActiveRecord::RecordNotFound => e
		logger.debug 	"TerminatorNinja finding problem finding kopter\#(#{kopter_id}) and order\##{order_id}"
	rescue
		logger.debug "TerminatorNinja fighting Confucius, no idea what happened!"
	else
		cancel_job(@order.job_id) if @order.job_id	# first off cancel background job handling it right now
		num_returns 	= @order.products.count
		product_name	= @order.stock_item.name
		lock_name		= "#{product_name}_inventory"

		Sidekiq.redis do |connection|
			Redis::Semaphore.new("#{lock_name}", redis: connection) do
				inv = connection.hincrby("inventory", product_name, num_returns)
			end
		end
		@order.transaction do
			@order.stock_item.set_inventory
			@order.trickle_down_status("cancel")
			@order.stock_item.sync_inventory		
		end
		logger.info {"TerminatorNinja says \"Asta la vista baby!\" to order\##{order_id}"}
	end

	def cancel_job(job_id)
		Sidekiq.redis {|connection| connection.setex("cancelled-#{job_id}", 86400, 1)}
	end
end