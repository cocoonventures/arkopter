module Arkopter
	module Status
		extend self
		 # note2self: don't freakin' use symbols, they're evil (Sidekiq hates them), strings only
		# if upgraded to Rails 4.2, switch to ActiveRecord enum new type
		STATUSES = ["processing", "on-arkopter", "in-transit", "delivered"].freeze

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
end