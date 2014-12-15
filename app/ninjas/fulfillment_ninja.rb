# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

class FulfillmentNinja

	include Sidekiq::Worker

	sidekiq_options queue: "fulfillment", backtrace: true
	sidekiq_options retry: true

	def perform(order_id)
		@order = Order.find(order_id)
	rescue ActiveRecord::RecordNotFound => e
		logger.debug "FulfillmentNinja can't find order \#: (#{id})"
	rescue
		logger.debug "FulfillmentNinja fighting Confucius, no idea what happened!"
	else
		until load_quad_arkopter do
			logger.debug {"Go to sleep punk! sleeper_hold engaged"}
			sleeper_hold  									# wait for transportation arrival
		end
		dispatch_quad_arkopter if @order.on_arkopter? 		# while waiting for an available helicopter state could have changed
															# like the order could cancel but for some reason this code continues
															# so dispatching a helicopter has the condition
	end	

	def load_quad_arkopter
		if (@q = QuadArkopter.reserve).present?
			# lock db rows
			@order.transaction do
				@order.quad_arkopter = @q 					# assign arkopter to order
				@order.quad_arkopter.status = "loaded-up"
				@order.save!
			end 
			@order.trickle_down_status("on-arkopter") 		# trickle has it's own lock
		else
			logger "There are no QuadArkopters available!"
			return false
		end 
	rescue
		logger.debug "Problem updating Order #{@order.id}, deal with this later"
		# raise ActiveRecord::Rollback # not sure this is the right thing to do
	else 
		return true
	end

	def sleeper_hold(taps=10)
		# this feels like the right thing to do because if there are no QuadArkopter
		# then the worker is pointless right now until they are provisioned. 
		logger.debug "Make ninja rest up. Hopefully QuadArkopters manifest soon"
		sleep taps.seconds
	end

	def dispatch_quad_arkopter
		logger.info		{"Dispatcing Order \##{@order.id} on #{@order.quad_arkopter.name})"}
		@order.transaction do
			@order.trickle_down_status("en-route")
			@order.quad_arkopter.status = "cargo-check"
			# recycling job_id, if we got this far then this worker is done, assigning next job to it
			# offloading delivery to the CargoNinja
			@order.job_id = CargoNinja.perform_async(@order.quad_arkopter_id, @order.id)
			@order.save!
		end 
	rescue
		logger.debug 	{"Problem dispatching Order #{@order.id}, job may be compromised"}
	else
		logger.info		{"Sending Order \##{@order.id} to CargoNinja (job: #{@order.job_id})"}
	end
end