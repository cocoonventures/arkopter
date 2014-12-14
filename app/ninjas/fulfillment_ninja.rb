# 
#                                 Copyright © 2012-13 Michael Kahlil Madison II. 
#

class FulfillmentNinja

	include Sidekiq::Worker

	sidekiq_options queue: "fulfillment", backtrace: true
	sidekiq_options retry: true

	def perform(order_id)
		o = Order.find(id)
	rescue ActiveRecord::RecordNotFound => e
		logger.debug "FulfillmentNinja can't find order \#: (#{id})"
	rescue
		logger.debug "FulfillmentNinja fighting Confucius, no idea what happened!"
	else
		
		dispatch_quad_arkopters 
	end	

	# this can be broken out into its own Worker
	def dispatch_quad_arkopters
	end
end