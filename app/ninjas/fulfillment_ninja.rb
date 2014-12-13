# 
#                                 Copyright © 2012-13 Michael Kahlil Madison II. 
#

class FulfillmentNinja

	include Sidekiq::Worker

	sidekiq_options queue: "fulfillment", backtrace: true
	sidekiq_options retry: true

	def perform(action, *arguments)
		@options = arguments.last.is_a?(Hash) ? arguments.pop : {}

		if self.class.method_defined?(action) or self.class.private_method_defined?(action)
			if arguments.size > 0
				self.send(action,*arguments)
			else
				self.send(action)
			end
		end
	end 

	def fulfill_order(id)
		o = Order.find(id)
	rescue
		logger.debug "FulfillmentNinja can't find order \#: (#{id})"
	else
		dispatch_quad_arkopters
	end	

	def dispatch_quad_arkopters
	end
end