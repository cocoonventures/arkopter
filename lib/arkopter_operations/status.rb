module ArkopterOperations
	module Status
		extend self

		 # note2self: don't freakin' use symbols, they're evil (Sidekiq hates them), strings only
		# if upgraded to Rails 4.2, switch to ActiveRecord enum new type
		STATUSES = ["warehoused","processing", "on-arkopter", "en-route", "delivered", "cancelled"].freeze

		def status=(new_status)
			if valid_status?(new_status)
			  	self.status = new_status
			  	
			else 
				logger.debug "Don't be stupid, use a valid status: #{new_status} isn't in #{STATUSES.inspect}"
				self.status 	# return the old status
			end
		end

		def valid_status?(new_status)
			STATUSES.include?(new_status)
		end
	end
	module KopterStatus
		extend Status
		extend self
		
		STATUSES = ["ready", "loaded-up", "en-route", "in-redeployment"].freeze		
	end
end