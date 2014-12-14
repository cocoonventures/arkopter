# 
#                                 Copyright © 2014- Michael Kahlil Madison II. 
#

class FulfillmentNinja

	include Sidekiq::Worker

	sidekiq_options queue: "fulfillment", backtrace: true
	sidekiq_options retry: true

	def perform(order_id)
		order = Order.find(order_id)
	rescue ActiveRecord::RecordNotFound => e
		logger.debug "FulfillmentNinja can't find order \#: (#{id})"
	rescue
		logger.debug "FulfillmentNinja fighting Confucius, no idea what happened!"
	else
		load_quad_arkopter
	end	

	def load_quad_arkopter
	end
	# this can be broken out into its own Worker
	def dispatch_quad_arkopter
	end
end