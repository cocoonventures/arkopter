# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

class TerminatorNinja

	include Sidekiq::Worker

	sidekiq_options queue: "terminator", backtrace: true
	sidekiq_options retry: true

	def perform(order_id)
		logger.info {"TerminatorNinja reminds Orders\##{order_id} he said he'd be back"}
		@order 		= Order.find(order_id)
		@arkopter 	= (@order.quad_arkopter.present?) ? QuadArkopter.find(@order.quad_arkopter) : nil
	rescue ActiveRecord::RecordNotFound => e
		logger.debug 	"TerminatorNinja problem finding kopter\#(#{@arkopter_id}) and order\##{order_id}"
	rescue
		logger.debug "TerminatorNinja fighting Confucius, no idea what happened!"
	else
		logger.info {"TerminatorNinja ready to destory Order\##{order_id}"}
		cancel_job(@order.job_id) if @order.job_id.present?	# first off cancel background job handling it right now

		repossess_inventory
		redeploy
		logger.info {"TerminatorNinja says \"Asta la vista baby!\" to order\##{order_id}"}
	end

	def repossess_inventory
		logger.info {"TerminatorNinja repossession in process!"}
		kill_names = []
		@order.products.each{ |p| kill_names << p.stock_item.name if !kill_names.include?(p.stock_item.name)}
		kill_names.uniq! # to be safe

		kill_names.each do |kill_name|
			stock_item		= StockItem.where(name: kill_name).take
			num_returns 	= @order.products.where(stock_item_id: stock_item.id).count or 0
			lock_name		= "#{kill_name}_inventory"

			Sidekiq.redis do |connection|
				Redis::Semaphore.new("#{lock_name}", redis: connection) do
						inv = connection.hincrby("inventory", kill_name, num_returns)
				end
			end
			stock_item.sync_inventory
			stock_item.save
		end
	rescue
		logger.debug {"TerminatorNinja repossession failed!"}
	else
		logger.info {"TerminatorNinja repossession successful!"}
	end

	def redeploy
		logger.info {"TerminatorNinja redeployment in process!"}
		@order.transaction do
			#@order.stock_item.set_inventory
			@order.trickle_down_status("canceled")
			@order.quad_arkopter.status = "ready" if @arkopter.present?
			@order.save!		
		end
		logger.info {"TerminatorNinja redeployment successful!"}
	end

	def cancel_job(job_id)
		Sidekiq.redis {|connection| connection.setex("cancelled-#{job_id}", 86400, 1)}
	end
end